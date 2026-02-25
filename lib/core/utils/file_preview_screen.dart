import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

/// Accepts either a local [File] or a remote URL [String].
///
/// Usage — local file (from create task attachments):
/// ```dart
/// FilePreviewScreen.fromFile(file: myFile, fileName: 'photo.jpg')
/// ```
///
/// Usage — remote URL (from task details / chat):
/// ```dart
/// FilePreviewScreen.fromUrl(url: 'https://...', fileName: 'report.pdf')
/// ```
class FilePreviewScreen extends StatefulWidget {
  /// Local file — set when opened from device picker.
  final File? localFile;

  /// Remote URL — set when opened from a network attachment.
  final String? remoteUrl;

  final String fileName;

  /// Open a locally picked [File]
  const FilePreviewScreen.fromFile({
    super.key,
    required File file,
    required this.fileName,
  })  : localFile = file,
        remoteUrl = null;

  /// Open a remote URL
  const FilePreviewScreen.fromUrl({
    super.key,
    required String url,
    required this.fileName,
  })  : remoteUrl = url,
        localFile = null;

  bool get _isLocal => localFile != null;

  @override
  State<FilePreviewScreen> createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends State<FilePreviewScreen> {
  bool _isLoading = true;
  bool _isDownloading = false;
  double _loadProgress = 0;
  double _downloadProgress = 0;
  String? _localFilePath;
  String? _errorMessage;

  // PDF specific
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfController;

  bool get _isPdf => widget.fileName.toLowerCase().endsWith('.pdf');

  bool get _isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp']
      .any((ext) => widget.fileName.toLowerCase().endsWith(ext));

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _loadProgress = 0;
      });

      if (widget._isLocal) {
        // ✅ Local file — use directly, no download needed
        final file = widget.localFile!;
        if (!await file.exists()) {
          setState(() {
            _errorMessage = 'File not found on device.';
            _isLoading = false;
          });
          return;
        }
        setState(() {
          _localFilePath = file.path;
          _isLoading = false;
        });
      } else {
        // ✅ Remote URL — download to temp dir
        final dir = await getTemporaryDirectory();
        final safeFileName = widget.fileName
            .replaceAll(' ', '_')
            .replaceAll(RegExp(r'[^\w\.\-]'), '_');
        final filePath = '${dir.path}/$safeFileName';
        final file = File(filePath);

        if (!await file.exists()) {
          await Dio().download(
            widget.remoteUrl!,
            filePath,
            onReceiveProgress: (received, total) {
              if (total > 0 && mounted) {
                setState(() => _loadProgress = received / total);
              }
            },
          );
        }

        if (mounted) {
          setState(() {
            _localFilePath = filePath;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load file.\n${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadToDevice() async {
    // Local files — save a copy to Downloads
    final sourceUrl = widget._isLocal ? null : widget.remoteUrl;
    final sourceFile = widget.localFile;

    final cs = Theme.of(context).colorScheme;
    bool hasPermission = false;

    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();
      if (sdkInt >= 33) {
        hasPermission = true;
      } else {
        final status = await Permission.storage.request();
        if (status.isGranted) {
          hasPermission = true;
        } else if (status.isPermanentlyDenied) {
          if (!mounted) return;
          _showOpenSettingsDialog();
          return;
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Storage permission is required to download files.'),
            backgroundColor: cs.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
          return;
        }
      }
    } else {
      final status = await Permission.photos.request();
      if (status.isGranted) {
        hasPermission = true;
      } else if (status.isPermanentlyDenied) {
        if (!mounted) return;
        _showOpenSettingsDialog();
        return;
      }
    }

    if (!hasPermission) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      late String savePath;
      if (Platform.isAndroid) {
        savePath = '/storage/emulated/0/Download/${widget.fileName}';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        savePath = '${dir.path}/${widget.fileName}';
      }

      if (await File(savePath).exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('File already exists in Downloads.'),
          backgroundColor: cs.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        setState(() => _isDownloading = false);
        return;
      }

      if (widget._isLocal && sourceFile != null) {
        // ✅ Local file — just copy it to Downloads
        await sourceFile.copy(savePath);
      } else if (sourceUrl != null) {
        // ✅ Remote — download fresh
        await Dio().download(
          sourceUrl,
          savePath,
          onReceiveProgress: (received, total) {
            if (total > 0 && mounted) {
              setState(() => _downloadProgress = received / total);
            }
          },
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Saved to Downloads: ${widget.fileName}')),
          ],
        ),
        backgroundColor: cs.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Download failed: ${e.toString()}'),
        backgroundColor: cs.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Permission Required'),
        content: const Text(
          'Storage permission was permanently denied. '
              'Please enable it from app settings to download files.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<int> _getAndroidSdkInt() async {
    try {
      final result = await Process.run('getprop', ['ro.build.version.sdk']);
      return int.tryParse(result.stdout.toString().trim()) ?? 30;
    } catch (_) {
      return 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _isPdf
                  ? (_totalPages > 0
                  ? 'Page ${_currentPage + 1} of $_totalPages'
                  : 'PDF Document')
                  : _isImage
                  ? 'Image'
                  : 'File',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          if (_isDownloading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  value: _downloadProgress > 0 ? _downloadProgress : null,
                  strokeWidth: 2.5,
                  color: cs.primary,
                ),
              ),
            )
          else if (!_isLoading && _localFilePath != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Save to device',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.cloud_download_rounded, color: cs.primary, size: 20),
                ),
                onPressed: _downloadToDevice,
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cs.outlineVariant),
        ),
      ),
      body: _buildBody(cs),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                value: _loadProgress > 0 ? _loadProgress : null,
                strokeWidth: 3,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _loadProgress > 0
                  ? 'Loading... ${(_loadProgress * 100).toStringAsFixed(0)}%'
                  : widget._isLocal
                  ? 'Opening file...'
                  : 'Downloading file...',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: cs.errorContainer, shape: BoxShape.circle),
                child: Icon(Icons.error_outline_rounded, size: 40, color: cs.error),
              ),
              const SizedBox(height: 20),
              Text('Failed to load file',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16, color: cs.onSurface)),
              const SizedBox(height: 8),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadFile,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_localFilePath == null) return const SizedBox();

    if (_isPdf) return _buildPdfViewer(cs);
    if (_isImage) return _buildImageViewer(cs);

    // Unsupported type
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file_rounded, size: 72, color: cs.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('Preview not available',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text('This file type cannot be previewed.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _downloadToDevice,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download File'),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer(ColorScheme cs) {
    return Stack(
      children: [
        PDFView(
          key: ValueKey(_localFilePath),
          filePath: _localFilePath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          fitEachPage: true,
          defaultPage: _currentPage,
          backgroundColor: cs.surfaceContainerLow,
          onRender: (pages) {
            if (mounted) setState(() => _totalPages = pages ?? 0);
          },
          onPageChanged: (page, total) {
            if (mounted) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages = total ?? 0;
              });
            }
          },
          onViewCreated: (controller) => _pdfController = controller,
          onError: (error) {
            if (mounted) setState(() => _errorMessage = error.toString());
          },
          onPageError: (page, error) {
            debugPrint('PDF page $page error: $error');
          },
        ),
        if (_totalPages > 0)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.inverseSurface.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: TextStyle(
                    color: cs.onInverseSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageViewer(ColorScheme cs) {
    return PhotoView(
      imageProvider: FileImage(File(_localFilePath!)),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 4,
      backgroundDecoration: BoxDecoration(color: cs.surfaceContainerLow),
      heroAttributes: PhotoViewHeroAttributes(
        tag: widget._isLocal ? widget.localFile!.path : widget.remoteUrl!,
      ),
      loadingBuilder: (context, event) => Center(
        child: CircularProgressIndicator(
          value: event?.expectedTotalBytes != null
              ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
              : null,
          color: cs.primary,
        ),
      ),
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_rounded, size: 64, color: cs.error),
            const SizedBox(height: 12),
            Text('Failed to display image',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}