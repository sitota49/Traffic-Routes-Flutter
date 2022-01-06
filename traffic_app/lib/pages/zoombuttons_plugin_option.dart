import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

class ZoomButtonsPluginOption extends LayerOptions {
  final int minZoom;
  final int maxZoom;
  final bool mini;
  final double padding;
  final Alignment alignment;
  final Color? zoomInColor;
  final Color? zoomInColorIcon;
  final Color? zoomOutColor;
  final Color? zoomOutColorIcon;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;

  ZoomButtonsPluginOption({
    Key? key,
    this.minZoom = 1,
    this.maxZoom = 18,
    this.mini = true,
    this.padding = 2.0,
    this.alignment = Alignment.topRight,
    this.zoomInColor,
    this.zoomInColorIcon,
    this.zoomInIcon = Icons.zoom_in,
    this.zoomOutColor,
    this.zoomOutColorIcon,
    this.zoomOutIcon = Icons.zoom_out,
    Stream<Null>? rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class ZoomButtonsPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is ZoomButtonsPluginOption) {
      return ZoomButtons(options, mapState, stream);
    }
    throw Exception('Unknown options type for ZoomButtonsPlugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is ZoomButtonsPluginOption;
  }
}

class ZoomButtons extends StatefulWidget {
  final ZoomButtonsPluginOption zoomButtonsOpts;
  final MapState map;
  final Stream<Null> stream;

  ZoomButtons(this.zoomButtonsOpts, this.map, this.stream)
      : super(key: zoomButtonsOpts.key);

  @override
  _ZoomButtonsState createState() => _ZoomButtonsState();
}

class _ZoomButtonsState extends State<ZoomButtons> {
  final FitBoundsOptions options =
      const FitBoundsOptions(padding: EdgeInsets.all(12.0));

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.zoomButtonsOpts.alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: widget.zoomButtonsOpts.padding,
                top: widget.zoomButtonsOpts.padding,
                right: widget.zoomButtonsOpts.padding),
            child: FloatingActionButton(
              heroTag: 'zoomInButton',
              mini: widget.zoomButtonsOpts.mini,
              backgroundColor: widget.zoomButtonsOpts.zoomInColor ??
                  Theme.of(context).primaryColor,
              onPressed: () {
                var bounds = widget.map.getBounds();
                var centerZoom =
                    widget.map.getBoundsCenterZoom(bounds, options);
                var zoom = centerZoom.zoom + 1;
                if (zoom < widget.zoomButtonsOpts.minZoom) {
                  zoom = widget.zoomButtonsOpts.minZoom as double;
                } else {
                  widget.map.move(centerZoom.center, zoom,
                      source: MapEventSource.custom);
                }
              },
              child: Icon(widget.zoomButtonsOpts.zoomInIcon,
                  // color: zoomButtonsOpts.zoomInColorIcon ??
                  //     IconTheme.of(context).color
                  color: Colors.black),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(widget.zoomButtonsOpts.padding),
            child: FloatingActionButton(
              heroTag: 'zoomOutButton',
              mini: widget.zoomButtonsOpts.mini,
              backgroundColor: widget.zoomButtonsOpts.zoomOutColor ??
                  Theme.of(context).primaryColor,
              onPressed: () {
                var bounds = widget.map.getBounds();
                var centerZoom =
                    widget.map.getBoundsCenterZoom(bounds, options);
                var zoom = centerZoom.zoom - 1;
                if (zoom > widget.zoomButtonsOpts.maxZoom) {
                  zoom = widget.zoomButtonsOpts.maxZoom as double;
                } else {
                  widget.map.move(centerZoom.center, zoom,
                      source: MapEventSource.custom);
                }
              },
              child: Icon(widget.zoomButtonsOpts.zoomOutIcon,
                  // color: zoomButtonsOpts.zoomOutColorIcon ??
                  //     IconTheme.of(context).color
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
