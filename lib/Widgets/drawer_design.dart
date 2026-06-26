import 'package:aio_tech/Widgets/aio_tech_logo.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_services.dart';

class DrawerDesign extends StatelessWidget {

  final Function(int) onDestinationSelected;
  final int selectedIndex;
  final AuthService _authService = AuthService();

   DrawerDesign({
    super.key,
    required this.onDestinationSelected,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBackground.withOpacity(0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: AIOTechLogo(),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Menu",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.search, color: AppColors.iconColor),
            title: const Text(
              "Smart Search",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            selected: selectedIndex == 2,
            onTap: () => onDestinationSelected(2),
          ),
          ListTile(
            leading: const Icon(
              Icons.balance,
              color: AppColors.iconColor,
            ),
            title: const Text(
              "Compare",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            selected: selectedIndex == 5,
            onTap: () => onDestinationSelected(5),
          ),
          ListTile(
            leading: const Icon(
              Icons.favorite_border,
              color: AppColors.iconColor,
            ),
            title: const Text(
              "WatchList",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            selected: selectedIndex == 3,
            onTap: () => onDestinationSelected(3),
          ),
          ListTile(
            leading: const Icon(
              Icons.person_outline,
              color: AppColors.iconColor,
            ),
            title: const Text(
              "DashBoard",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            selected: selectedIndex == 4,
            onTap: () => onDestinationSelected(4),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                children: const [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "History",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Icon(Icons.access_time, color: Colors.white, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey),
          Padding(
            padding: EdgeInsets.all(15),
            child: ListTile(
              trailing: IconButton(
                icon: Icon(Icons.logout, color: AppColors.iconColor, size: 40),
                isSelected: selectedIndex == 0,
                onPressed: () => onDestinationSelected(0),
              ),
              leading: Icon(
                Icons.account_circle,
                color: AppColors.iconColor,
                size: 40,
              ),
              title: FutureBuilder<String?>(
                future: _authService.getFullName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      "Loading...",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    );
                  }
                  return Text(
                    snapshot.data ?? "Guest",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              subtitle: Text(
                "Free plan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
