// import 'package:flutter/foundation.dart';

import 'package:packnary/models/pack_member.dart';

class PackFile {
  String imageURL;
  PackMember uploader;
  String uploadedAt;

  PackFile({
    this.imageURL,
    this.uploader,
    this.uploadedAt,
  });
}
