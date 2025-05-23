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

  // New state for expanded nav bar
  bool _isNavBarExpanded = false;

  void _navigateTo(ShellPage page,
      {String? name, String? memberId, VoidCallback? onCancelLogin}) {
    setState(() {
      // When navigating away, collapse nav bar
      _isNavBarExpanded = false;

      if (page == ShellPage.login) {
        _previousPage = _currentPage;
      }

      if (page == ShellPage.nameBoard && name != null) {
        _selectedName = name.toLowerCase();
      } else if (page != ShellPage.nameBoard) {
        _selectedName = null;
      }

      if (page == ShellPage.messagePanel && memberId != null) {
        _selectedMemberId = memberId;
      } else if (page != ShellPage.messagePanel) {
        _selectedMemberId = null;
      }

      _currentPage = page;
    });
  }

  void _returnAfterLogin() {
    setState(() {
      _isNavBarExpanded = false;

      if (_previousPage == ShellPage.nameBoard && _selectedName != null) {
        _currentPage = ShellPage.nameBoard;
      } else if (_previousPage != null) {
        _currentPage = _previousPage!;
      } else {
        _currentPage = ShellPage.trending;
      }
      _previousPage = null;
    });
  }

  // Toggle nav bar expansion state
  void _toggleNavBarExpansion() {
    setState(() {
      _isNavBarExpanded = !_isNavBarExpanded;
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

  // Simulated login state (you may want to replace with real auth check)
  bool get isLoggedIn => _currentPage != ShellPage.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < -10) {
            // Swipe up - expand nav bar
            if (!_isNavBarExpanded) {
              _toggleNavBarExpansion();
            }
          } else if (details.delta.dy > 10) {
            // Swipe down - collapse nav bar
            if (_isNavBarExpanded) {
              _toggleNavBarExpansion();
            }
          }
        },
        child: _buildPage(),
      ),
      bottomNavigationBar: CustomNavBar(
        currentPage: _currentPage,
        isExpanded: _isNavBarExpanded,
        isLoggedIn: isLoggedIn,
        onToggleExpansion: _toggleNavBarExpansion,
        onNavigate: (page,
            {String? name, String? memberId, VoidCallback? onCancelLogin}) {
          _navigateTo(page,
              name: name, memberId: memberId, onCancelLogin: onCancelLogin);
        },
      ),
    );
  }
}
