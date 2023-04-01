import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/back_widget.dart';
import '../../component/loader_widget.dart';
import '../../main.dart';
import '../../model/provider_for_service.dart';
import '../../network/rest_apis.dart';
import '../../utils/images.dart';
import 'components/provider_widget.dart';

class ProvidersScreen extends StatefulWidget {
  final int serviceId;
  final String serviceName;
  final int? categoryId;

  const ProvidersScreen({this.categoryId, required this.serviceName, required this.serviceId, Key? key})
      : super(key: key);

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  Future<ProviderForService>? future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(transparentColor);

    future = getProvidersForService(serviceId: widget.serviceId.validate(), categoryId: widget.categoryId);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget buildBodyWidget(AsyncSnapshot<ProviderForService> snap) {
    if (snap.hasError) {
      return Text(snap.error.toString()).center();
    } else if (snap.hasData) {
      return snap.data!.data!.isNotEmpty
          ? ListView.builder(
        itemCount: snap.data!.pagination!.totalItems,
        itemBuilder: (BuildContext context, int index) {
          return ProviderWidget(data: snap.data!.data![index], serviceId: widget.serviceId.validate());
        },
      )
          : Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(notDataFoundImg, height: 126),
            32.height,
            Text(language.lblNoProviders, style: boldTextStyle()),
          ],
        ),
      ).center();
    }
    return LoaderWidget().center();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.serviceName,
        color: context.primaryColor,
        textColor: white,
        backWidget: BackWidget(),
      ),
      body: FutureBuilder<ProviderForService>(
        future: future,
        builder: (context, snap) {
          return SafeArea(
            child: Scaffold(
              body: buildBodyWidget(snap),
            ),
          );
        },
      ),
    );
  }
}