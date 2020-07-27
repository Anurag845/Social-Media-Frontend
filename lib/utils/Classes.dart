import 'dart:ui';

class Filter {
  String effectId;
  String effectName;
  Color color1;
  Color color2;

  Filter(this.effectId,this.effectName,this.color1,this.color2);
}

class PhotoEffectArgs {
  String imagePath;
  Filter filter;

  PhotoEffectArgs(this.imagePath,this.filter);
}

class UserDetails {
  final String providerDetails;
  final String userName;
  final String photoUrl;
  final String userEmail;
  final List<ProviderDetails> providerData;

  UserDetails(this.providerDetails,this.userName, this.photoUrl,this.userEmail, this.providerData);
}


class ProviderDetails {
  ProviderDetails(this.providerDetails);
  final String providerDetails;
}