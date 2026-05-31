import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLoading = true;
  
  bool isLikeComment = false;
  bool isFromFriends = false;
  bool isRequestedFriend = false;
  bool isSuggestedFriend = false;
  bool isBirthday = false;
  bool isVideo = false;
  bool isReport = false;
  bool isSoundOn = false;
  bool isNotificationOn = false;
  bool isVibrantOn = false;
  bool isLedOn = false;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    final token = context.read<AuthCubit>().state.token ?? "mock_token";
    final response = await ApiService.getPushSettings(token);
    if (mounted) {
      if (response['code'] == '1000' || response['code'] == '200' || response['code'] == 1000) {
        final data = response['data'];
        if (data != null) {
          setState(() {
            isLikeComment = _parseBool(data['likeComment']);
            isFromFriends = _parseBool(data['fromFriends']);
            isRequestedFriend = _parseBool(data['requestedFriend']);
            isSuggestedFriend = _parseBool(data['suggestedFriend']);
            isBirthday = _parseBool(data['birthday']);
            isVideo = _parseBool(data['video']);
            isReport = _parseBool(data['report']);
            isSoundOn = _parseBool(data['soundOn']);
            isNotificationOn = _parseBool(data['notificationOn']);
            isVibrantOn = _parseBool(data['vibrantOn']);
            isLedOn = _parseBool(data['ledOn']);
            
            isLoading = false;
          });
          return;
        }
      }
      
      setState(() {
        isLoading = false;
      });
      // Nếu API get ban đầu chưa có các field này, ta vẫn hiển thị form
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải cài đặt: ${response['message']}')));
    }
  }

  Future<void> _updateSetting() async {
    final token = context.read<AuthCubit>().state.token ?? "mock_token";
    final response = await ApiService.setPushSettings(
      token: token,
      likeComment: isLikeComment,
      fromFriends: isFromFriends,
      requestedFriend: isRequestedFriend,
      suggestedFriend: isSuggestedFriend,
      birthday: isBirthday,
      video: isVideo,
      report: isReport,
      soundOn: isSoundOn,
      notificationOn: isNotificationOn,
      vibrantOn: isVibrantOn,
      ledOn: isLedOn,
    );

    if (mounted && response['code'] != '1000' && response['code'] != '200' && response['code'] != 1000) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi cập nhật: ${response['message']}')));
    }
  }

  bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is int) return val == 1;
    if (val is String) return val == '1' || val.toLowerCase() == 'true' || val.toLowerCase() == 'on';
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 1,
        title: const Text('Cài đặt thông báo', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                SwitchListTile(
                  title: const Text('Bật thông báo đẩy', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: isNotificationOn,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => isNotificationOn = val);
                    _updateSetting();
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Tương tác (Like/Comment)', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: isLikeComment,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => isLikeComment = val);
                    _updateSetting();
                  },
                ),
                SwitchListTile(
                  title: const Text('Từ bạn bè', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: isFromFriends,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => isFromFriends = val);
                    _updateSetting();
                  },
                ),
                SwitchListTile(
                  title: const Text('Yêu cầu kết bạn', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: isRequestedFriend,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => isRequestedFriend = val);
                    _updateSetting();
                  },
                ),
                SwitchListTile(
                  title: const Text('Gợi ý kết bạn', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: isSuggestedFriend,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => isSuggestedFriend = val);
                    _updateSetting();
                  },
                ),
                SwitchListTile(
                  title: const Text('Sinh nhật', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: isBirthday,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => isBirthday = val);
                    _updateSetting();
                  },
                ),
                SwitchListTile(
                  title: const Text('Video', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: isVideo,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => isVideo = val);
                    _updateSetting();
                  },
                ),
                SwitchListTile(
                  title: const Text('Báo cáo (Report)', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: isReport,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => isReport = val);
                    _updateSetting();
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Âm thanh', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: isSoundOn,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => isSoundOn = val);
                    _updateSetting();
                  },
                ),
                SwitchListTile(
                  title: const Text('Rung (Vibrant)', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: isVibrantOn,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => isVibrantOn = val);
                    _updateSetting();
                  },
                ),
                SwitchListTile(
                  title: const Text('Đèn LED', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: isLedOn,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => isLedOn = val);
                    _updateSetting();
                  },
                ),
              ],
            ),
    );
  }
}
