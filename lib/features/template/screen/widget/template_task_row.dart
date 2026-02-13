import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/template_models.dart';

class TemplateTaskRow extends StatelessWidget {
  final TemplateTask task;

  const TemplateTaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20, bottom: 14),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green
                      .withOpacity(0.2),
                  borderRadius:
                  BorderRadius.circular(
                      10),
                ),
                child: const Icon(
                  Icons.description,
                  size: 18,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.taskName,
                  style: const TextStyle(
                      fontSize: 14),
                ),
              ),
            ],
          ),

          /// FILES
          if (task.files.isNotEmpty)
            Container(
              margin:
              const EdgeInsets.only(
                  top: 12),
              padding:
              const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(
                    0xff112D24),
                borderRadius:
                BorderRadius.circular(
                    18),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    "Attachments (${task.files.length})",
                    style:
                    const TextStyle(
                        fontWeight:
                        FontWeight
                            .w600),
                  ),
                  const SizedBox(height: 10),
                  ...task.files.map(
                        (f) => Row(
                      children: [
                        const Icon(
                          Icons
                              .attach_file,
                          color: Colors
                              .greenAccent,
                        ),
                        const SizedBox(
                            width: 10),
                        Expanded(
                          child: Text(
                            f.remoteFilePath
                                .split('/')
                                .last,
                            overflow:
                            TextOverflow
                                .ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons
                              .download,
                          color: Colors
                              .greenAccent,
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
