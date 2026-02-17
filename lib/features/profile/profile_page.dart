import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/profile_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.isProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          if (user == null) {
            return const Center(child: Text("No Data Found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildTile("User ID", user.userId.toString()),

                const SizedBox(height: 10),

                _buildTile("Name", user.userName),
                _buildTile("Email", user.userEmail),
                _buildTile("Mobile", user.userMobileNumber),
                _buildTile("Designation", user.designation),
                _buildTile("User Type", user.userTypeName),
                _buildTile("Company Name", user.companyName),
                _buildTile("Company Type", user.companyType),
                _buildTile("Profile Type", user.profileType),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value.isEmpty ? "-" : value),
      ),
    );
  }
}
