import 'package:flutter/material.dart';
import 'custom_nav_bar.dart';
import 'trending_board.dart';
import 'home_page.dart';
import 'login.dart';
import 'profile.dart';
import 'message_panel.dart';

enum ShellPage { trending, nameBoard, login, profile, messagePanel }

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  ShellPage _currentPage = ShellPage.trending;
  ShellPage? _previousPage;
  String? _selectedName;
  String? _selectedMemberId;

  void _navigateTo(ShellPage page, {String? name, String? memberId}) {
    setState(() {
      if (page == ShellPage.login) {
        // Remember current page before going to login
        _previousPage = _currentPage;
      }

      // Update selected name only when going to nameBoard
      if (page == ShellPage.nameBoard && name != null) {
        _selectedName = name.toLowerCase();
      } else if (page != ShellPage.nameBoard) {
        // Only clear if we're leaving nameBoard page
        _selectedName = null;
      }

      // Update selected memberId only when going to messagePanel
      if (page == ShellPage.messagePanel && memberId != null) {
        _selectedMemberId = memberId;
      } else if (page != ShellPage.messagePanel) {
        // Only clear if we're leaving messagePanel page
        _selectedMemberId = null;
      }

      // Update current page regardless, to force rebuild
      _currentPage = page;
    });
  }

  void _returnAfterLogin() {
    setState(() {
      if (_previousPage == ShellPage.nameBoard && _selectedName != null) {
        _currentPage = ShellPage.nameBoard;
      } else if (_previousPage != null) {
        _currentPage = _previousPage!;
      } else {
        _currentPage = ShellPage.trending;
      }
      _previousPage = null; // clear previous page after returning
    });
  }

  Widget _buildPage() {
    switch (_currentPage) {
      case ShellPage.trending:
        return TrendingBoardsPage(
          onNameSelected: (name) =>
              _navigateTo(ShellPage.nameBoard, name: name),
        );
      case ShellPage.nameBoard:
        if (_selectedName == null) {
          return const Center(child: Text('No name selected'));
        }
        return VoodooBoardHomePage(name: _selectedName!);
      case ShellPage.login:
        return LoginPage(
          currentMemberName: _selectedName,
          onLoginSuccess: _returnAfterLogin,
        );
      case ShellPage.profile:
        return const ProfilePage();
      case ShellPage.messagePanel:
        if (_selectedMemberId == null) {
          return const Center(child: Text('No member selected'));
        }
        return MessagePanel(memberId: _selectedMemberId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(),
      bottomNavigationBar: CustomNavBar(
        currentPage: _currentPage,
        onNavigate: (page, {String? name, String? memberId}) {
          _navigateTo(page, name: name, memberId: memberId);
        },
      ),
    );
  }
}
