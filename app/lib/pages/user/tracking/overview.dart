import 'dart:async';
import 'dart:developer';

import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/service/delivery/tracking_service.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/status.dart';
import 'package:app/types/user/type.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/sliding_up/map_viewer_single-point._path-finder.widget.dart';
import 'package:app/widget/sliding_up/map_viewer_multiple-point.widget.dart';
import 'package:app/widget/tracking/job_container.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../config/share/app_data.dart';

class OverviewPage extends StatefulWidget {
  final bool? initialTabIsSender;

  const OverviewPage({super.key, this.initialTabIsSender});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool _isActiveTabSender = true;
  bool _isLoading = true;

  List<Map<String, dynamic>> _senderJobsGrouped = [];
  List<Map<String, dynamic>> _receiverJobsGrouped = [];

  DeliveryJob? _selectedJobForMap;
  bool _isMapOpen = false;
  bool _isMultipleMapOpen = false;
  List<DeliveryJob> _selectedJobsForMultipleMap = [];

  StreamSubscription<List<Map<String, dynamic>>>? _senderSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _receiverSubscription;

  @override
  void initState() {
    super.initState();
    _isActiveTabSender = widget.initialTabIsSender ?? true;
    _startRealtimeStreams();
  }

  void _startRealtimeStreams() {
    final appData = Provider.of<AppData>(context, listen: false);

    try {
      setState(() {
        _isLoading = true;
      });

      _senderSubscription =
          TrackingService.watchDeliveryJobsByUserIdGroupedByDate(
            appData.currentUser!.id,
            UserType.sender,
          ).listen(
            (senderJobsGrouped) {
              if (mounted) {
                setState(() {
                  _senderJobsGrouped = senderJobsGrouped;
                  _isLoading = false;
                });
              }
            },
            onError: (error) {
              log('Sender stream error: $error');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          );

      _receiverSubscription =
          TrackingService.watchDeliveryJobsByUserIdGroupedByDate(
            appData.currentUser!.id,
            UserType.receiver,
          ).listen(
            (receiverJobsGrouped) {
              if (mounted) {
                setState(() {
                  _receiverJobsGrouped = receiverJobsGrouped;
                  _isLoading = false;
                });
              }
            },
            onError: (error) {
              log('Receiver stream error: $error');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _senderSubscription?.cancel();
    _receiverSubscription?.cancel();
    super.dispose();
  }

  void _handleLocationPress(DeliveryJob job) {
    // log("Handle location press work for delivery: ${job.deliveryId}");
    // log("Delivery status: ${job.status}");
    // log("Is rider tracking status: ${_isRiderTrackingStatus(job.status)}");

    setState(() {
      _selectedJobForMap = job;
      _isMapOpen = false;
    });

    // log("After setState - _isMapOpen: $_isMapOpen");
    // log(
    //   "After setState - _selectedJobForMap is null: ${_selectedJobForMap == null}",
    // );

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isMapOpen = true;
        });
        // log("Delayed setState - _isMapOpen: $_isMapOpen");
      }
    });
  }

  int _getTotalJobCount(List<Map<String, dynamic>> groupedJobs) {
    int total = 0;
    for (final group in groupedJobs) {
      final jobs = group['jobs'] as List<DeliveryJob>;
      total += jobs.length;
    }
    return total;
  }

  bool _isRiderTrackingStatus(StatusType status) {
    return status == StatusType.receiving || status == StatusType.riding;
  }

  void _openMultipleMapWithJobs(List<DeliveryJob> jobs) {
    log("Open multiple map with job");
    log("Jobs count: ${jobs.length}");

    if (jobs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่มีรายการจัดส่งให้แสดงบนแผนที่'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final List<DeliveryJob> newSelection = List<DeliveryJob>.from(jobs);
    final bool wasMapOpen = _isMultipleMapOpen;

    setState(() {
      _selectedJobsForMultipleMap = newSelection;
      _isMultipleMapOpen = wasMapOpen ? false : true;
    });

    if (wasMapOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _isMultipleMapOpen = true;
        });
      });
    }

    log(
      "Multiple map state set: wasOpen=$wasMapOpen, reopened=$_isMultipleMapOpen, selection length=${_selectedJobsForMultipleMap.length}",
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    return MainLayout(
      scrollable: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: ShapeDecoration(
                        color: AppColors.primary5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3F819067),
                            blurRadius: 8,
                            offset: Offset(0, 1.50),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Text(
                              appData.currentUser?.name ?? '???',
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 14,
                                fontFamily: 'Mali',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _isLoading
                          ? 'กำลังโหลดข้อมูล...'
                          : _isActiveTabSender
                          ? _senderJobsGrouped.isEmpty
                                ? 'ไม่มีพัสดุที่ส่ง'
                                : '${_getTotalJobCount(_senderJobsGrouped)} รายการส่งพัสดุ'
                          : _receiverJobsGrouped.isEmpty
                          ? 'ไม่มีพัสดุที่รับ'
                          : '${_getTotalJobCount(_receiverJobsGrouped)} รายการรับพัสดุ',
                      style: TextStyle(
                        color: const Color(0xFF819067) /* Primary-Green2 */,
                        fontSize: 10,
                        fontFamily: 'Mali',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // ButtonActions(
                    //   variant: ButtonVariant.primary,
                    //   icon: Icons.map,
                    //   onPressed: _openMultipleMap,
                    // ),
                    // SizedBox(width: 8),
                    ButtonActions(
                      variant: ButtonVariant.danger,
                      icon: Icons.close,
                      onPressed: () {
                        Get.offNamed("/");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ButtonUnderline(
                  text: "ส่งพัสดุ",
                  active: _isActiveTabSender,
                  onPressed: () {
                    log("On tab sender work");
                    setState(() {
                      _isActiveTabSender = true;
                    });
                  },
                ),
              ),
              Expanded(
                child: ButtonUnderline(
                  text: "รับพัสดุ",
                  active: !_isActiveTabSender,
                  onPressed: () {
                    log("On tab receiver work");
                    setState(() {
                      _isActiveTabSender = false;
                    });
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'กำลังโหลดข้อมูล...',
                          style: TextStyle(
                            fontFamily: 'Mali',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _isActiveTabSender && _senderJobsGrouped.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            "ไม่มีรายการส่งพัสดุ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontFamily: 'Mali',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "เมื่อคุณส่งพัสดุ รายการจะแสดงที่นี่",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontFamily: 'Mali',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : !_isActiveTabSender && _receiverJobsGrouped.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            "ไม่มีรายการรับพัสดุ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontFamily: 'Mali',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "เมื่อมีคนส่งพัสดุให้คุณ รายการจะแสดงที่นี่",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontFamily: 'Mali',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          if (_isActiveTabSender)
                            ..._senderJobsGrouped.map((group) {
                              final date = group['date'] as String;
                              final jobs = group['jobs'] as List<DeliveryJob>;
                              return JobContainerView(
                                onContainerPress: (jobsContainer) {
                                  _openMultipleMapWithJobs(jobsContainer);
                                },
                                deliveryJobs: jobs,
                                title: "รายการส่งพัสดุ",
                                date: DateTime.parse(date.replaceAll('/', '-')),
                                onLocationPress: _handleLocationPress,
                              );
                            })
                          else
                            ..._receiverJobsGrouped.map((group) {
                              final date = group['date'] as String;
                              final jobs = group['jobs'] as List<DeliveryJob>;
                              return JobContainerView(
                                onContainerPress: (jobsContainer) {
                                  _openMultipleMapWithJobs(jobsContainer);
                                },
                                deliveryJobs: jobs,
                                title: "รายการรับพัสดุ",
                                date: DateTime.parse(date.replaceAll('/', '-')),
                                onLocationPress: _handleLocationPress,
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
          ),
          if (_selectedJobForMap != null)
            // Single Tracking
            MapViewerSinglePointPathFinder(
              isShowingDetail: false,
              key: ValueKey("overview_${_selectedJobForMap!.deliveryId}"),
              isOpened: _isMapOpen,
              // delivery address
              lat: _selectedJobForMap!.deliveryAddress.latitude,
              lng: _selectedJobForMap!.deliveryAddress.longtitude,
              destLabel: _selectedJobForMap!.deliveryAddress.detail,
              // pickup address
              originLat: _selectedJobForMap!.pickupAddress.latitude,
              originLng: _selectedJobForMap!.pickupAddress.longtitude,
              originLabel: _selectedJobForMap!.pickupAddress.detail,
              deliveryId: _selectedJobForMap!.deliveryId,
              trackRiderLocation:
                  _isRiderTrackingStatus(_selectedJobForMap!.status),
              label:
                  // "${_isRiderTrackingStatus(_selectedJobForMap!.status) ? "ตำแหน่งไรเดอร์และจุดหมาย" : "จุดหมาย"} - ${StatusTypes().getStatusMeaning(_selectedJobForMap!.status)}",
                  "${_isRiderTrackingStatus(_selectedJobForMap!.status) ? "ตำแหน่งไรเดอร์และจุดหมาย" : "จุดหมาย"} - ${_selectedJobForMap!.deliveryId}",
              mode: _isRiderTrackingStatus(_selectedJobForMap!.status)
                  ? PathFinderMode.currentToDestination
                  : PathFinderMode.originToDestination,
              locationUpdateInterval: const Duration(seconds: 10),
              locationUpdateDistance: 5,
              aspectRatio: 9 / 12,
              onModalClosed: () {
                setState(() {
                  _isMapOpen = false;
                  _selectedJobForMap = null;
                });
              },
              content: Column(
                children: [
                  Text(
                    "รายละเอียดการส่งพัสดุ",
                    style: TextStyle(
                      fontFamily: 'Mali',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    StatusTypes().getStatusMeaning(_selectedJobForMap!.status),
                    style: TextStyle(
                      fontFamily: 'Mali',
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 24,
                    children: [
                      Column(
                        spacing: 12,
                        children: [
                          Text("รูปภาพการเข้ารับสินค้า"),
                          ProfileWidgets.avatar(
                            shape: ProfileShape.rectangle,
                            isEdited: false,
                            config: ProfileWidgetConfig(
                              placeholderIcon: Icons.inbox_outlined,
                            ),
                            imageUrl:
                                _selectedJobForMap!
                                    .pickupPkgImagesUrl
                                    .isNotEmpty
                                ? _selectedJobForMap!.pickupPkgImagesUrl.first
                                : "",
                          ),
                        ],
                      ),

                      Column(
                        spacing: 12,
                        children: [
                          Text("รูปภาพการส่งสินค้า"),
                          ProfileWidgets.avatar(
                            shape: ProfileShape.rectangle,
                            isEdited: false,
                            config: ProfileWidgetConfig(
                              placeholderIcon: Icons.inbox_outlined,
                            ),
                            imageUrl: _selectedJobForMap!.sendedPkgImgUrl,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

          MapViewerMultiplePoint(
            key: ValueKey(
              'multiple_map_${_selectedJobsForMultipleMap.map((job) => job.deliveryId).join('_')}',
            ),
            deliveryJobs: _selectedJobsForMultipleMap,
            isOpened: _isMultipleMapOpen,
            label: _isActiveTabSender
                ? "แผนที่จุดส่ง (${_selectedJobsForMultipleMap.length} จุด)"
                : "แผนที่จุดรับ (${_selectedJobsForMultipleMap.length} จุด)",
            aspectRatio: 9 / 12,
            onModalClosed: () {
              log("MapViewerMultiplePoint closed");
              setState(() {
                _isMultipleMapOpen = false;
                _selectedJobsForMultipleMap = [];
              });
            },
          ),
        ],
      ),
    );
  }
}
