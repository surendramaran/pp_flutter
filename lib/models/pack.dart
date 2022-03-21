import 'package:packnary/models/pack_member.dart';

import 'pack_file.dart';

class Pack {
  int packId;
  String packName;
  String packType;
  PackMember admin;
  List<PackMember> members;
  String createdAt;
  List<PackFile> files;
  bool isMember;

  Pack({
    this.packId,
    this.packName,
    this.packType,
    this.admin,
    this.members,
    this.createdAt,
    this.files,
    this.isMember,
  });
}
