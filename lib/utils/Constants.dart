import 'package:navras/utils/Classes.dart';

class Constants {
  static const ADMIN_EMAIL = "admin@admin.com";

  static const PORT = 3000;
  static const IP ='svn.ethdc.in'; //only change this by your IPv4 Address
  static const SERVER_URL = 'http://$IP:$PORT/api/';
  static const SERVER_IMAGE_URL = 'http://$IP:$PORT/';
  static const USERS_PROFILES_URL = 'http://$IP:$PORT/uploads/users_profile_img/';
  static const USERS_POSTS_IMAGES = 'http://$IP:$PORT/uploads/users_posts_img/';
  static const USERS_MESSAGES_IMAGES = 'http://$IP:$PORT/uploads/users_messages_img/';
  static const PUBLIC_ROOMS_IMAGES = 'http://$IP:$PORT/uploads/public_chat_rooms/';
  static const CATEGORY_IMAGES = 'http://$IP:$PORT/uploads/categories/';
  static const GROUP_IMAGES = 'http://$IP:$PORT/uploads/groups/';
  static const SOCKET_URL = 'http://$IP:$PORT';


  static const GoogleSignInPageRoute = 'googlesignin';
  static const CreateProfilePageRoute = 'createprofile';
  static const ExpressListPageRoute = 'expresslist';
  static const HomePageRoute = 'home';
  static const PostsPageRoute = 'landingpage';
  static const AllGroupsPageRoute = 'allgroups';
  static const AllCategoriesPageRoute = 'allcategories';
  static const CreatePostPageRoute = 'createpost';
  static const LoginPageRoute = 'login';
  static const ChatMessagesPageRoute = 'chatmessages';
  static const CommentsPageRoute = 'comments';
  static const CreateGroupPageRoute = 'creategroup';
  static const GroupChatsPageRoute = 'groupchats';
  static const InviteMembersPageRoute = 'invitemembers';
  static const NotificatitonPageRoute = 'notifications';
  static const ProfilePageRoute = 'profilepage';
  static const PersonalChatsPageRoute = 'personalchats';
  static const MomentPageRoute = 'sharemoment';
  static const MomentPreviewPageRoute = 'momentpreview';
  static const MemoryPageRoute = 'sharememory';
  static const CaptureTalentPageRoute = 'capturetalent';
  static const TalentPreviewPageRoute = 'talentpreview';
  static const PhotoEditorPageRoute = 'photoeditor';
  static const VideoEffectsPageRoute = 'videoeditor';
  static const LocationPageRoute = 'location';
  static const SingleCategoryPageRoute = 'singlecategory';
  static const SingleGroupPageRoute = 'singlegroup';
  static const SplashScreenRoute = 'splashscreen';
  static const WelcomePageRoute = 'welcome';

  static List<Filter> filters = List<Filter>();

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