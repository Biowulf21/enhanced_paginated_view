import 'package:enhanced_paginated_view/enhanced_paginated_view.dart';
import 'package:enhanced_paginated_view/src/core/custom_type_def.dart';
import 'package:enhanced_paginated_view/src/models/enhanced_loading_type.dart';
import 'package:enhanced_paginated_view/src/models/enhanced_view_type.dart';
import 'package:enhanced_paginated_view/src/views/enhanced_box_view.dart';
import 'package:enhanced_paginated_view/src/views/enhanced_sliver_view.dart';
import 'package:enhanced_paginated_view/src/widgets/loading_widget.dart';
import 'package:enhanced_paginated_view/src/widgets/error_page_widget.dart';
import 'package:flutter/material.dart';

/// This is the EnhancedPaginatedView widget.
/// It provides a paginated view of items of type [T].
class EnhancedPaginatedView<T> extends StatefulWidget {
  /// Constructs an EnhancedPaginatedView widget.
  ///
  /// The [onLoadMore] function is called when the user reaches the end of the list.
  /// The [hasReachedMax] boolean is used to control the loading widget.
  /// The [itemsPerPage] integer controls the number of items loaded per page.
  /// The [delegate] is an instance of [EnhancedDelegate] that provides data and status information.
  /// The [boxBuilder] is a builder function for creating a box-based view.
  /// The [direction] specifies the direction of the enhanced paginated view.
  /// The [hasRefreshEnabled] boolean determines if the refresh indicator is enabled.
  /// The [onRefresh] function is called when the user pulls down to refresh the view.
  /// The [refreshIndicatorBuilder] is a builder function for the refresh indicator.
  factory EnhancedPaginatedView({
    required void Function(int) onLoadMore,
    required bool hasReachedMax,
    int itemsPerPage = 15,
    required EnhancedDelegate<T> delegate,
    required EnhancedBoxBuilder<T> builder,
    EnhancedViewDirection direction = EnhancedViewDirection.forward,
    bool hasRefreshEnabled = false,
    Future<void> Function()? onRefresh,
    Widget Function(BuildContext, Widget)? refreshIndicatorBuilder,
  }) {
    return EnhancedPaginatedView._(
      type: EnhancedViewType.box,
      onLoadMore: onLoadMore,
      direction: direction,
      hasReachedMax: hasReachedMax,
      itemsPerPage: itemsPerPage,
      delegate: delegate,
      boxBuilder: builder,
      sliverBuilder: null,
      hasRefreshEnabled: hasRefreshEnabled,
      onRefresh: onRefresh,
      refreshIndicatorBuilder: refreshIndicatorBuilder,
    );
  }

  /// Constructs an EnhancedPaginatedView widget with a CustomScrollView-based view.
  ///
  /// The [onLoadMore] function is called when the user reaches the end of the list.
  /// The [hasReachedMax] boolean is used to control the loading widget.
  /// The [itemsPerPage] integer controls the number of items loaded per page.
  /// The [delegate] is an instance of [EnhancedDelegate] that provides data and status information.
  /// The [sliverBuilder] is a builder function for creating a sliver-based view.
  /// The [direction] specifies the direction of the enhanced paginated view.
  /// The [hasRefreshEnabled] boolean determines if the refresh indicator is enabled.
  /// The [onRefresh] function is called when the user pulls down to refresh the view.
  /// The [refreshIndicatorBuilder] is a builder function for the refresh indicator.
  factory EnhancedPaginatedView.slivers({
    required void Function(int) onLoadMore,
    required bool hasReachedMax,
    int itemsPerPage = 15,
    required EnhancedDelegate<T> delegate,
    required EnhancedSliverBuilder<T> builder,
    EnhancedViewDirection direction = EnhancedViewDirection.forward,
    bool hasRefreshEnabled = false,
    Future<void> Function()? onRefresh,
    Widget Function(BuildContext, Widget)? refreshIndicatorBuilder,
  }) {
    return EnhancedPaginatedView._(
      onLoadMore: onLoadMore,
      type: EnhancedViewType.sliver,
      direction: direction,
      hasReachedMax: hasReachedMax,
      itemsPerPage: itemsPerPage,
      delegate: delegate,
      boxBuilder: null,
      sliverBuilder: builder,
      hasRefreshEnabled: hasRefreshEnabled,
      onRefresh: onRefresh,
      refreshIndicatorBuilder: refreshIndicatorBuilder,
    );
  }

  // Private constructor
  const EnhancedPaginatedView._({
    required this.onLoadMore,
    required this.hasReachedMax,
    required this.itemsPerPage,
    required this.type,
    required this.delegate,
    required this.boxBuilder,
    required this.sliverBuilder,
    required this.direction,
    required this.hasRefreshEnabled,
    required this.onRefresh,
    required this.refreshIndicatorBuilder,
    super.key,
  }) : assert(!hasRefreshEnabled || onRefresh != null,
            'onRefresh must be provided if hasRefreshEnabled is true');

  /// [hasReachedMax] is a boolean that controls the loading widget.
  ///
  /// This boolean is set to true when the list reaches the end.
  final bool hasReachedMax;

  /// [itemsPerPage] is an integer that controls the number of items loaded per page.
  ///
  /// This helps with requesting the right page number from the server
  /// in case of delete or update operations.
  ///
  /// The default value is 15.
  final int itemsPerPage;

  /// [type] specifies the type of the view.
  ///
  /// The default value is [EnhancedViewType.box].
  final EnhancedViewType type;

  /// [onLoadMore] is a function that is called when the user reaches the end of the list.
  ///
  /// This function is required and should take an integer parameter representing the current page.
  final void Function(int) onLoadMore;

  /// Specifies the direction of the enhanced paginated view.
  ///
  /// The [EnhancedViewDirection] enum is used to determine the scrolling direction
  /// of the enhanced paginated view. It can be set to either [EnhancedViewDirection.forward]
  /// or [EnhancedViewDirection.reverse].
  ///
  /// Example usage:
  /// ```dart
  /// final EnhancedViewDirection direction = EnhancedViewDirection.vertical;
  /// ```
  final EnhancedViewDirection direction;

  /// [delegate] is an instance of [EnhancedDelegate] that provides data and status information.
  final EnhancedDelegate<T> delegate;

  /// [boxBuilder] is a builder function for creating a box-based view.
  final EnhancedBoxBuilder<T>? boxBuilder;

  /// [sliverBuilder] is a builder function for creating a sliver-based view.
  final EnhancedSliverBuilder<T>? sliverBuilder;

  /// [hasRefreshEnabled] is a boolean that determines if the refresh indicator is enabled.
  final bool hasRefreshEnabled;

  /// [onRefresh] is a function that is called when the user pulls down to refresh the view.
  final Future<void> Function()? onRefresh;

  /// [refreshIndicatorBuilder] is a builder function for the refresh indicator.
  final Widget Function(BuildContext, Widget)? refreshIndicatorBuilder;
  @override
  State<EnhancedPaginatedView<T>> createState() =>
      _EnhancedPaginatedViewState<T>();
}

class _EnhancedPaginatedViewState<T> extends State<EnhancedPaginatedView<T>> {
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  late int _loadThreshold;

  /// Returns the current page number.
  int get page => widget.delegate.listOfData.length ~/ widget.itemsPerPage + 1;

  /// Loads more data when called.
  ///
  /// This function is called only if [_isLoading] is false.
  void loadMore() {
    if (_isLoading) return;
    _isLoading = true;
    widget.onLoadMore(page);
    // Use a delayed Future to reset the loading flag after a short delay
    Future.delayed(const Duration(milliseconds: 250), () => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadThreshold = widget.itemsPerPage - 3;
  }

  /// Checks if more data needs to be loaded and loads it if necessary.
  void checkAndLoadDataIfNeeded() {
    if (widget.hasReachedMax ||
        widget.delegate.status == EnhancedStatus.loading ||
        widget.delegate.status == EnhancedStatus.error) {
      return;
    }

    if (widget.delegate.listOfData.length <= _loadThreshold) {
      // Load more data when the list gets shorter than the minimum threshold
      if (page < 2) {
        loadMore();
      }
    }
  }

  /// Handles scroll notifications and loads more data if necessary.
  ///
  /// Returns false to allow the notification to continue to be dispatched.
  bool onNotification(ScrollNotification scrollInfo) {
    if (widget.hasReachedMax ||
        widget.delegate.status == EnhancedStatus.loading ||
        widget.delegate.status == EnhancedStatus.error) {
      return false;
    }

    if (scrollInfo is ScrollUpdateNotification) {
      // Check if the last 5 items are visible
      final lastVisibleIndex = _scrollController.position.maxScrollExtent -
          scrollInfo.metrics.pixels;
      if (lastVisibleIndex <= 100) {
        // The last 5 items are visible
        // You can now take appropriate action
        loadMore();
      }
    }
    return false;
  }

  @override
  void didUpdateWidget(covariant EnhancedPaginatedView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkAndLoadDataIfNeeded();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: onNotification,
      child: widget.delegate.status == EnhancedStatus.loading && page == 1
          ? LoadingWidget(
              config: widget.delegate.loadingConfig,
              type: EnhancedLoadingType.page,
            )
          : widget.delegate.status == EnhancedStatus.error && page == 1
              ? ErrorPageWidget(config: widget.delegate.errorPageConfig)
              : switch (widget.type) {
                  EnhancedViewType.sliver => EnhancedSliverView<T>(
                      delegate: widget.delegate,
                      builder: widget.sliverBuilder!,
                      page: page,
                      scrollController: _scrollController,
                      direction: widget.direction,
                    ),
                  EnhancedViewType.box => EnhancedBoxView<T>(
                      delegate: widget.delegate,
                      builder: widget.boxBuilder!,
                      page: page,
                      scrollController: _scrollController,
                      direction: widget.direction,
                      hasRefreshEnabled: widget.hasRefreshEnabled,
                      onRefresh: widget.onRefresh,
                    ),
                },
    );
  }
}
