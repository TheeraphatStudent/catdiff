import 'dart:developer';

import 'package:app/config/theme/app_theme.dart';
import 'package:app/service/upload/post.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

enum ProfileSize { xxs, xs, sm, md, xl }

enum ProfileShape { circular, rectangle }

class ProfileController extends ChangeNotifier {
  File? _selectedFile;
  String? _imageUrl;
  String? _uploadedUrl;
  bool _isUploading = false;
  String? _error;

  // Getters
  File? get selectedFile => _selectedFile;
  String? get imageUrl => _imageUrl;
  String? get uploadedUrl => _uploadedUrl;
  bool get isUploading => _isUploading;
  bool get hasImage =>
      _selectedFile != null || _imageUrl != null || _uploadedUrl != null;
  String? get error => _error;
  String? get currentImageUrl => _uploadedUrl ?? _imageUrl;

  // Setters
  void setImageUrl(String? url) {
    _imageUrl = url;
    _error = null;
    notifyListeners();
  }

  void setSelectedFile(File? file) {
    _selectedFile = file;
    _error = null;
    notifyListeners();
  }

  void clearImage() {
    _selectedFile = null;
    _imageUrl = null;
    _uploadedUrl = null;
    _error = null;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<String?> uploadProfile(String userId) async {
    log("Upload profile work");

    if (_selectedFile == null) return _uploadedUrl;

    log("Continue to upload...");

    try {
      _isUploading = true;
      _error = null;
      notifyListeners();

      // First check if storage is accessible
      log("Checking storage access...");
      final storageAccessible = await UploadService.checkStorageAccess();
      if (!storageAccessible) {
        log("Storage access check failed - proceeding anyway");
        // Don't fail here, let the upload attempt proceed
      }

      // Try upload with retry logic for better reliability
      final uploadedUrl = await UploadService.uploadProfileImageWithRetry(
        _selectedFile!,
        userId,
        maxRetries: 3,
      );

      if (uploadedUrl != null) {
        _uploadedUrl = uploadedUrl;
        _selectedFile = null;
        log("Upload successful: $uploadedUrl");
      } else {
        _error = 'Failed to upload image - please check your internet connection and try again';
        log("Upload failed: no URL returned");
      }

      return uploadedUrl;
    } catch (e) {
      log('Upload failed with exception: $e');
      _error = 'Upload failed: ${e.toString()}';

      // Provide user-friendly error messages
      if (e.toString().contains('permission-denied')) {
        _error = 'Permission denied - please check app permissions';
      } else if (e.toString().contains('network-request-failed')) {
        _error = 'Network error - please check your internet connection';
      } else if (e.toString().contains('object-not-found')) {
        _error = 'Storage configuration error - please contact support';
      } else if (e.toString().contains('quota-exceeded')) {
        _error = 'Storage quota exceeded - please contact support';
      }

      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// ========== Style config ==========
class ProfileWidgetConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color overlayColor;
  final Color placeholderColor;
  final Color placeholderIconColor;
  final IconData placeholderIcon;
  final IconData editIcon;
  final double borderWidth;

  const ProfileWidgetConfig({
    this.backgroundColor = const Color(0xFF001E01),
    this.borderColor = const Color(0xFF0A400C),
    this.overlayColor = const Color(0xFF0A400C),
    this.placeholderColor = const Color(0xFFE0E0E0),
    this.placeholderIconColor = const Color(0xFF9E9E9E),
    this.placeholderIcon = Icons.person,
    this.editIcon = Icons.edit,
    this.borderWidth = 1.0,
  });

  static const ProfileWidgetConfig dark = ProfileWidgetConfig();

  static const ProfileWidgetConfig light = ProfileWidgetConfig(
    backgroundColor: Colors.white,
    borderColor: Color(0xFFE0E0E0),
    overlayColor: Color(0xFF007AFF),
    placeholderColor: Color(0xFFF5F5F5),
    placeholderIconColor: Color(0xFF9E9E9E),
  );
}

// ========== Size helper ==========
class ProfileDimensions {
  final double containerSize;
  final double imageSize;
  // final double iconSize;
  final double padding;
  final double borderRadius;
  final double imageBorderRadius;

  const ProfileDimensions({
    required this.containerSize,
    required this.imageSize,
    // required this.iconSize,
    required this.padding,
    required this.borderRadius,
    required this.imageBorderRadius,
  });

  static ProfileDimensions getDimensions(ProfileSize size, ProfileShape shape) {
    late double containerSize;
    late double imageSize;

    switch (size) {
      case ProfileSize.xxs:
        containerSize = 32;
        imageSize = 28;
        break;
      case ProfileSize.xs:
        containerSize = 64;
        imageSize = 60;
        break;
      case ProfileSize.sm:
        containerSize = 88;
        imageSize = 84;
        break;
      case ProfileSize.md:
        containerSize = 128;
        imageSize = 124;
        break;
      case ProfileSize.xl:
        containerSize = 256;
        imageSize = 252;
        break;
    }

    // final iconSize = 20.0;
    final padding = 0.0;
    final borderRadius = shape == ProfileShape.circular
        ? containerSize / 2
        : _getRectangleBorderRadius(size);
    final imageBorderRadius = shape == ProfileShape.circular
        ? imageSize / 2
        : _getImageBorderRadius(size);

    return ProfileDimensions(
      containerSize: containerSize,
      imageSize: imageSize,
      // iconSize: iconSize,
      padding: padding,
      borderRadius: borderRadius,
      imageBorderRadius: imageBorderRadius,
    );
  }

  static double _getRectangleBorderRadius(ProfileSize size) {
    switch (size) {
      case ProfileSize.xxs:
        return 4;
      case ProfileSize.xs:
        return 6;
      case ProfileSize.sm:
        return 8;
      case ProfileSize.md:
        return 12;
      case ProfileSize.xl:
        return 16;
    }
  }

  static double _getImageBorderRadius(ProfileSize size) {
    switch (size) {
      case ProfileSize.xxs:
        return 2;
      case ProfileSize.xs:
        return 4;
      case ProfileSize.sm:
        return 6;
      case ProfileSize.md:
        return 8;
      case ProfileSize.xl:
        return 12;
    }
  }
}

// ========== Widget ==========
class ProfileWidget extends StatefulWidget {
  final bool isEdited;
  final ProfileSize size;
  final ProfileShape shape;
  final ProfileController? controller;
  final String? imageUrl;
  final File? initialImage;
  final Function(File?)? onImageSelected;
  final Function(String)? onError;
  final Function(String?)? onUrlChanged;
  final ProfileWidgetConfig config;
  final bool showEditIcon;
  final String? heroTag;
  final int imageQuality;
  final bool enableCamera;
  final bool enableGallery;
  final String? placeholder;
  final bool autoUpload;
  final String? userId;

  const ProfileWidget({
    Key? key,
    required this.isEdited,
    required this.size,
    this.shape = ProfileShape.circular,
    this.controller,
    this.imageUrl,
    this.initialImage,
    this.onImageSelected,
    this.onError,
    this.onUrlChanged,
    this.config = ProfileWidgetConfig.dark,
    this.showEditIcon = true,
    this.heroTag,
    this.imageQuality = 80,
    this.enableCamera = true,
    this.enableGallery = true,
    this.placeholder,
    this.autoUpload = false,
    this.userId,
  }) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

// ========== State ==========
class _ProfileWidgetState extends State<ProfileWidget>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late ProfileDimensions _dimensions;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  ProfileController? _internalController;

  ProfileController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _internalController = ProfileController();
      if (widget.imageUrl != null) {
        _internalController!.setImageUrl(widget.imageUrl);
      }
      if (widget.initialImage != null) {
        _internalController!.setSelectedFile(widget.initialImage);
      }
    }

    _dimensions = ProfileDimensions.getDimensions(widget.size, widget.shape);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _animationController.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    if (_controller.error != null && widget.onError != null) {
      widget.onError!(_controller.error!);
    }
    if (widget.onUrlChanged != null) {
      widget.onUrlChanged!(_controller.currentImageUrl);
    }
  }

  @override
  void didUpdateWidget(ProfileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size || oldWidget.shape != widget.shape) {
      _dimensions = ProfileDimensions.getDimensions(widget.size, widget.shape);
    }
  }

  void _handleError(String message) {
    _controller.setError(message);
    if (widget.onError != null) {
      widget.onError!(message);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    log("Pick image from source work");

    if (!widget.isEdited) return;

    log("Continue to next step...");

    try {
      _controller.clearError();

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: widget.imageQuality,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      log("Image picked: ${image?.path}");

      if (image != null) {
        final File imageFile = File(image.path);
        _controller.setSelectedFile(imageFile);

        widget.onImageSelected?.call(imageFile);

        if (widget.autoUpload && widget.userId != null) {
          await _controller.uploadProfile(widget.userId!);
        }
      }
    } catch (e) {
      _handleError('Failed to pick image: ${e.toString()}');
    }
  }

  void _removeImage() {
    _controller.clearImage();
    widget.onImageSelected?.call(null);
  }

  Future<void> _showImageSourceDialog() async {
    if (!widget.isEdited) return;

    final options = <Widget>[];

    if (widget.enableGallery) {
      options.add(
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('Gallery'),
          onTap: () {
            Navigator.pop(context);
            _pickImageFromSource(ImageSource.gallery);
          },
        ),
      );
    }

    if (widget.enableCamera) {
      options.add(
        ListTile(
          leading: const Icon(Icons.photo_camera),
          title: const Text('Camera'),
          onTap: () {
            Navigator.pop(context);
            _pickImageFromSource(ImageSource.camera);
          },
        ),
      );
    }

    if (_controller.hasImage) {
      options.add(
        ListTile(
          leading: Icon(Icons.delete, color: Colors.red[600]),
          title: Text('Remove Image', style: TextStyle(color: Colors.red[600])),
          onTap: () {
            Navigator.pop(context);
            _removeImage();
          },
        ),
      );
    }

    if (options.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                ...options,
              ],
            ),
          ),
        );
      },
    );
  }

  // ========== Widget builder ==========
  Widget _buildImageWidget() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isUploading) {
          return Container(
            width: _dimensions.imageSize,
            height: _dimensions.imageSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                _dimensions.imageBorderRadius,
              ),
              color: widget.config.placeholderColor,
            ),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.config.overlayColor,
                  ),
                ),
              ),
            ),
          );
        }

        Widget imageWidget;

        if (_controller.selectedFile != null) {
          imageWidget = Container(
            width: _dimensions.imageSize,
            height: _dimensions.imageSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                _dimensions.imageBorderRadius,
              ),
              image: DecorationImage(
                image: FileImage(_controller.selectedFile!),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else if (_controller.currentImageUrl != null &&
            _controller.currentImageUrl!.isNotEmpty) {
          imageWidget = Container(
            width: _dimensions.imageSize,
            height: _dimensions.imageSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                _dimensions.imageBorderRadius,
              ),
              image: DecorationImage(
                image: NetworkImage(_controller.currentImageUrl!),
                fit: BoxFit.cover,
                onError: (error, stackTrace) {
                  _handleError('Failed to load image from URL');
                },
              ),
            ),
          );
        } else {
          imageWidget = Container(
            width: _dimensions.imageSize,
            height: _dimensions.imageSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                _dimensions.imageBorderRadius,
              ),
              color: widget.config.placeholderColor,
            ),
            child: widget.placeholder != null
                ? Center(
                    child: Text(
                      widget.placeholder!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.config.placeholderIconColor,
                      ),
                    ),
                  )
                : Icon(
                    widget.config.placeholderIcon,
                    size: 24,
                    color: widget.config.placeholderIconColor,
                  ),
          );
        }

        return widget.heroTag != null
            ? Hero(tag: widget.heroTag!, child: imageWidget)
            : imageWidget;
      },
    );
  }

  Widget _buildEditOverlay() {
    if (!widget.isEdited || !widget.showEditIcon)
      return const SizedBox.shrink();

    // double overlaySize = _dimensions.containerSize * 0.25;
    double overlaySize = _dimensions.containerSize * 0.25;
    double overlayBorderRadius = widget.shape == ProfileShape.circular
        ? overlaySize / 2
        : overlaySize * 0.2;

    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: overlaySize,
        height: overlaySize,
        decoration: BoxDecoration(
          color: widget.config.overlayColor,
          borderRadius: BorderRadius.circular(overlayBorderRadius),
          border: Border.all(color: widget.config.backgroundColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          widget.config.editIcon,
          size: overlaySize * 0.5,
          color: AppColors.white,
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isEdited) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isEdited) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.isEdited) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEdited ? _showImageSourceDialog : null,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: _dimensions.containerSize,
              height: _dimensions.containerSize,
              padding: EdgeInsets.all(_dimensions.padding),
              decoration: ShapeDecoration(
                color: widget.config.backgroundColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: widget.config.borderWidth,
                    color: widget.config.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(_dimensions.borderRadius),
                ),
                shadows: widget.isEdited
                    ? [
                        BoxShadow(
                          color: widget.config.borderColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [_buildImageWidget(), _buildEditOverlay()],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ====================================
// ========== Usage here kub ==========
// ====================================
class ProfileWidgets {
  static Widget managed({
    required ProfileController controller,
    required bool isEdited,
    ProfileSize size = ProfileSize.md,
    ProfileShape shape = ProfileShape.circular,
    ProfileWidgetConfig config = ProfileWidgetConfig.dark,
    bool autoUpload = false,
    String? userId,
  }) {
    return ProfileWidget(
      isEdited: isEdited,
      size: size,
      shape: shape,
      controller: controller,
      config: config,
      autoUpload: autoUpload,
      userId: userId,
    );
  }

  static Widget avatar({
    required bool isEdited,
    String? imageUrl,
    File? initialImage,
    Function(File?)? onImageSelected,
    ProfileSize size = ProfileSize.md,
    ProfileShape shape = ProfileShape.circular,
    ProfileWidgetConfig config = ProfileWidgetConfig.dark,
  }) {
    return ProfileWidget(
      isEdited: isEdited,
      size: size,
      shape: shape,
      imageUrl: imageUrl,
      initialImage: initialImage,
      onImageSelected: onImageSelected,
      config: config,
    );
  }

  static Widget placeholder({
    required ProfileSize size,
    String? text,
    ProfileShape shape = ProfileShape.circular,
    ProfileWidgetConfig config = ProfileWidgetConfig.dark,
  }) {
    return ProfileWidget(
      isEdited: false,
      size: size,
      shape: shape,
      placeholder: text,
      config: config,
      showEditIcon: false,
    );
  }

  static Widget editable({
    required Function(File?) onImageSelected,
    ProfileSize size = ProfileSize.md,
    ProfileShape shape = ProfileShape.circular,
    String? imageUrl,
    File? initialImage,
    ProfileWidgetConfig config = ProfileWidgetConfig.dark,
  }) {
    return ProfileWidget(
      isEdited: true,
      size: size,
      shape: shape,
      imageUrl: imageUrl,
      initialImage: initialImage,
      onImageSelected: onImageSelected,
      config: config,
    );
  }
}
