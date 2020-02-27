import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/composer.dart';
import 'src/search.dart';
import 'src/utils.dart';
import 'src/widgets.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Profile _profile;

  @override
  void initState() {
    super.initState();

    Provider.of<Client>(context, listen: false).currentUser
      .then((profile) => setState(() => _profile = profile));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit profile")),
      body: _profile == null ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            children: <Widget>[
              _EditAvatar(_profile),
              Divider(),
              _EditProfile(_profile),
            ]
          ),
        )
      )
    );
  }
}

class _EditAvatar extends StatefulWidget {
  _EditAvatar(this.profile);

  final Profile profile;

  @override
  State<StatefulWidget> createState() => _EditAvatarState();
}

class _EditAvatarState extends State<_EditAvatar> {
  static const double _size = 196;

  final _crop = GlobalKey<CropState>();
  File _newImage;
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final placeholder = Icon(Icons.person, size: _size);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Update profile picture", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: _newImage != null ? Container(
              width: _size,
              height: _size,
              child: _uploading ? Stack(
                children: <Widget>[
                  Image.file(_newImage),
                  Center(child: CircularProgressIndicator())
                ],
              ) : Crop(
                key: _crop,
                aspectRatio: 1,
                alwaysShowGrid: true,
                image: FileImage(_newImage),
              )
            ) : widget.profile.avatar != null ? ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                width: _size,
                height: _size,
                fit: BoxFit.fitWidth,
                imageUrl: widget.profile.avatar.large,
                placeholder: (context, url) => placeholder)
              ) : placeholder
          )
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: _newImage == null ? <Widget>[
                OutlineButton.icon(icon: Icon(Icons.photo_camera), label: Text("Take new picture"), onPressed: () => _pick(ImageSource.camera)),
                OutlineButton.icon(icon: Icon(Icons.photo_library), label: Text("Upload new picture"), onPressed: () => _pick(ImageSource.gallery))
              ] : !_uploading ? <Widget>[
                OutlineButton(child: Text("Save"), onPressed: _upload),
                OutlineButton(child: Text("Cancel"), onPressed: () => setState(() => _newImage = null))
              ] : <Widget>[],
            ),
          )
        )
      ],
    );
  }

  _pick(ImageSource source) async {
    // TODO recover from dying the background
    final image = await ImagePicker.pickImage(source: source, maxWidth: 700);

    if (image == null) {
      return; // user canceled
    }

    setState(() => _newImage = image);
  }

  _upload() async {
    setState(() => _uploading = true);
    try {
      final croppedImage = await ImageCrop.cropImage(
        file: _newImage,
        area: _crop.currentState.area,
        scale: _crop.currentState.scale
      );

      final photo = await Provider.of<Client>(context, listen: false).uploadProfilePicture(croppedImage);
      setState(() {
        widget.profile.avatar = photo.sizes;
        _uploading = false;
        _newImage = null;
      });
    } catch (e, s) {
      tryShowErrorSnackBar(this, "Failed to upload profile picture", e, s);

      setState(() {
        _uploading = false;
        _newImage = null;
      });
    }
  }
}

class _EditProfile extends StatefulWidget {
  _EditProfile(this.profile);

  final Profile profile;

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<_EditProfile> {
  Profile _profile;
  final _name = TextEditingController();
  final _nameFocus = FocusNode();
  final _location = TextEditingController();
  final _locationFocus = FocusNode();
  final _gender = TextEditingController();
  final _genderFocus = FocusNode();
  final _bio = TextEditingController();
  final _bioFocus = FocusNode();
  bool _bioInFocus = false;
  final _birthdayController = TextEditingController();
  DateTime _birthday;
  bool _birthdayIncludeYear;
  bool _publicProfile;
  bool _searchable;
  bool _nsfw;
  List<String> _tags;
  bool _hasChanges = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    _profile = widget.profile;
    _setFromProfile();

    _bioFocus.addListener((){
      if (_bioInFocus != _bioFocus.hasFocus) {
        setState(() => _bioInFocus = _bioFocus.hasFocus);
      }
    });
  }

  @override
  void didUpdateWidget(_EditProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      _profile = widget.profile;
      _setFromProfile();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Edit profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          onChanged: _validate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _name,
                focusNode: _nameFocus,
                enabled: !_submitting,
                decoration: InputDecoration(labelText: "Name"),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_locationFocus),
              ),
              TextFormField(
                controller: _location,
                focusNode: _locationFocus,
                enabled: !_submitting,
                decoration: InputDecoration(labelText: "Location"),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_genderFocus),
              ),
              TextFormField(
                controller: _gender,
                focusNode: _genderFocus,
                enabled: !_submitting,
                decoration: InputDecoration(labelText: "Gender"),
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_bioFocus),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text("Bio", style: TextStyle(fontSize: 16, color: _bioInFocus ? Theme.of(context).primaryColor : Theme.of(context).hintColor)),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.loose(Size(double.infinity, 200)),
                child: SimpleComposer(
                  controller: _bio,
                  focusNode: _bioFocus,
                  enabled: !_submitting
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: !_submitting ? _pickBirthday : null, // Wrapped in detector to eat the event for the child
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _birthdayController,
                          decoration: InputDecoration(labelText: "Birthday"),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: !_submitting && _birthday != null ? () {
                      setState(() => _birthday = null);
                      _updateBirthday();
                    } : null
                  ),
                  Switch(value: _birthdayIncludeYear, onChanged: !_submitting && _birthday != null ?  (includeYear) {
                    setState(() => _birthdayIncludeYear = includeYear);
                    _updateBirthday();
                  } : null),
                ]
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text("Make profile info public?"),
                value: _publicProfile,
                onChanged: !_submitting ? (value) {
                  setState(() => _publicProfile = value);
                  _validate();
                } : null
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text("Allow to be searched for?"),
                value: _searchable,
                onChanged: !_submitting ? (value) {
                  setState(() => _searchable = value);
                  _validate();
                } : null
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text("Mark profile as #nsfw?"),
                value: _nsfw,
                onChanged: !_submitting ? (value) {
                  setState(() => _nsfw = value);
                  _validate();
                } : null
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text("Tags", style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor)),
              ),
              Wrap(
                spacing: 4,
                children: _buildTagsContent()
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Visibility(
                    visible: !_submitting,
                    replacement: CircularProgressIndicator(),
                    child: OutlineButton(
                      child: Text("Update profile"),
                      onPressed: _hasChanges ? _submit : null,
                    ),
                  )
                ),
              )
            ]
          )
        ),
      )
    ],
  );

  @override
  void dispose() {
    super.dispose();

    _name.dispose();
    _nameFocus.dispose();
    _location.dispose();
    _locationFocus.dispose();
    _gender.dispose();
    _genderFocus.dispose();
    _bio.dispose();
    _bioFocus.dispose();
    _birthdayController.dispose();
  }

  _setFromProfile() {
    _name.text = _profile.person.name ?? "";
    _location.text = _profile.location ?? "";
    _gender.text = _profile.gender ?? "";
    _bio.text = _profile.bio ?? "";
    _birthdayController.text = _profile.formattedBirthday ?? "";

    setState(() {
      _birthday = _profile.birthday;
      _birthdayIncludeYear = _birthday == null || _birthday.year > Profile.birthdayYearThreshold;
      _publicProfile = _profile.public;
      _searchable = _profile.searchable;
      _nsfw = _profile.nsfw;
      _tags = List.of(_profile.tags ?? <String>[]);
    });
  }

  _pickBirthday() async {
    final now = DateTime.now(),
      newBirthday = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 13, now.month, now.day),
      firstDate: DateTime(1005),
      lastDate: DateTime(now.year - 13, now.month, now.day)
    );

    if (newBirthday == null) {
      return; // user canceled
    }

    setState(() {
      _birthday = newBirthday;
      if (newBirthday.year <= Profile.birthdayYearThreshold) {
        _birthdayIncludeYear = false;
      }
    });

    _updateBirthday();
  }

  _updateBirthday() {
    if (_birthday == null) {
      _birthdayController.text = "";
    } else if (_birthdayIncludeYear) {
      final date = _birthday.year > Profile.birthdayYearThreshold ? _birthday :
        DateTime(DateTime.now().year, _birthday.month, _birthday.day);
      _birthdayController.text = Profile.formatBirthday(date);
    } else {
      _birthdayController.text = Profile.formatBirthday(DateTime(
        Profile.birthdayYearThreshold, _birthday.month, _birthday.day));
    }

    _validate();
  }

  List<Widget> _buildTagsContent() {
    final tags = _tags.map<Widget>((tag) => Chip(
      label: Text("#$tag"),
      deleteIcon: Icon(Icons.remove_circle_outline),
      onDeleted: () {
        setState(() => _tags.remove(tag));
        _validate();
      },
    )).toList();

    if (_tags.length < 5) {
      tags.add(IconButton(
        icon: Icon(Icons.add),
        onPressed: () async {
          final response = await showDialog(context: context, builder: (context) => TagSearchDialog());

          if (response == null) {
            return; // user canceled
          }

          if (_tags.contains(response)) {
            Scaffold.of(context).showSnackBar(errorSnackbar(context, "Tag already added"));
            return;
          }

          setState(() => _tags.add(response));
          _validate();
        },
      ));
    }

    return tags;
  }

  _validate() {
    bool hasChanges =
      (_name.text != _profile.person.name) ||
      (_location.text != _profile.location) ||
      (_gender.text != _profile.gender) ||
      (_bio.text != _profile.bio) ||
      _birthdayHasChanges ||
      (_publicProfile != _profile.public) ||
      (_searchable != _profile.searchable) ||
      (_nsfw != _profile.nsfw) ||
      !containSameElements(_tags, _profile.tags);

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  bool get _birthdayHasChanges {
    if (_birthday == null) {
      return _profile.birthday != null;
    } else if (_profile.birthday == null) {
      return _birthday != null;
    }

    if (_birthday.month != _profile.birthday.month ||
        _birthday.day != _profile.birthday.day) {
      return true;
    }

    if (_profile.birthday.year > Profile.birthdayYearThreshold) {
      if (_birthdayIncludeYear) {
        return _birthday.year != _profile.birthday.year; // both say include year, check if it changed
      } else {
        return true; // changed to hide year
      }
    } else {
      return _birthdayIncludeYear; // changed to show year if true, no changes if false
    }
  }

  _submit() async {
    final client = Provider.of<Client>(context, listen: false);

    setState(() => _submitting = true);

    final birthday = _birthday == null || _birthdayIncludeYear ? _birthday :
      DateTime(Profile.birthdayYearThreshold, _birthday.month, _birthday.day);

    try {
      final newProfile = await client.updateProfile(ProfileUpdate(
        bio: _bio.text,
        birthday: birthday,
        gender: _gender.text,
        location: _location.text,
        name: _name.text,
        nsfw: _nsfw,
        searchable: _searchable,
        public: _publicProfile,
        tags: _tags
      ));

      _profile = newProfile;
      _validate();

      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Profile updated.")));
    } catch (e, s) {
      debugger();
      tryShowErrorSnackBar(this, "Failed to update profile", e, s);
    } finally {
      setState(() => _submitting = false);
    }
  }
}
