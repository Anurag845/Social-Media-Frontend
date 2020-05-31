//created by Hatem Ragap
class Constants {
  static const ADMIN_EMAIL = "admin@admin.com";

  static const PORT = 3000;
  static const IP ='192.168.43.18'; //only change this by your IPv4 Address
  static const SERVER_URL = 'http://$IP:$PORT/api/';
  static const SERVER_IMAGE_URL = 'http://$IP:$PORT/';
  static const USERS_PROFILES_URL = 'http://$IP:$PORT/uploads/users_profile_img/';
  static const USERS_POSTS_IMAGES = 'http://$IP:$PORT/uploads/users_posts_img/';
  static const USERS_MESSAGES_IMAGES = 'http://$IP:$PORT/uploads/users_messages_img/';
  static const PUBLIC_ROOMS_IMAGES = 'http://$IP:$PORT/uploads/public_chat_rooms/';
  static const CATEGORY_IMAGES = 'http://$IP:$PORT/uploads/categories/';
  static const GROUP_IMAGES = 'http://$IP:$PORT/uploads/groups/';
  static const SOCKET_URL = 'http://$IP:$PORT';



  // Go To https://apps.admob.com/ to get your app id and create banners and Interstitial

  static const ADMOB_APP_ID_ANDROID = 'ca-app-pub-5232255599483761~3493846395';
  static const ADMOB_APP_ID_IOS = 'ca-app-pub-5232255599483761~4721854505';

  //static const InterstitialAdUnitIdAndroid = 'ca-app-pub-5232255599483761/6886102974';
  static const InterstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';

  static const InterstitialAdUnitIdIOS = 'ca-app-pub-5232255599483761/8757587841';

  //static const BannerAdUnitIdAndroid = 'ca-app-pub-5232255599483761/3020408955';
  static const BannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';

  static const BannerAdUnitIdIOS = 'ca-app-pub-5232255599483761~4721854505';
}
