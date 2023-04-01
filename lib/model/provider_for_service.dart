class ProviderForService {
  Pagination? pagination;
  List<Data>? data;

  ProviderForService({this.pagination, this.data});

  ProviderForService.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pagination {
  int? totalItems;
  int? perPage;
  int? currentPage;
  int? totalPages;
  int? from;
  int? to;
  Null? nextPage;
  Null? previousPage;

  Pagination(
      {this.totalItems,
        this.perPage,
        this.currentPage,
        this.totalPages,
        this.from,
        this.to,
        this.nextPage,
        this.previousPage});

  Pagination.fromJson(Map<String, dynamic> json) {
    totalItems = json['total_items'];
    perPage = json['per_page'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
    from = json['from'];
    to = json['to'];
    nextPage = json['next_page'];
    previousPage = json['previous_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_items'] = this.totalItems;
    data['per_page'] = this.perPage;
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    data['from'] = this.from;
    data['to'] = this.to;
    data['next_page'] = this.nextPage;
    data['previous_page'] = this.previousPage;
    return data;
  }
}

class Data {
  int? providerId;
  String? providerName;
  int? status;
  int? isFeatured;
  String? providerImage;
  int? cityId;
  int? providertypeId;
  String? providertype;

  Data(
      {this.providerId,
        this.providerName,
        this.status,
        this.isFeatured,
        this.providerImage,
        this.cityId,
        this.providertypeId,
        this.providertype});

  Data.fromJson(Map<String, dynamic> json) {
    providerId = json['provider_id'];
    providerName = json['provider_name'];
    status = json['status'];
    isFeatured = json['is_featured'];
    providerImage = json['provider_image'];
    cityId = json['city_id'];
    providertypeId = json['providertype_id'];
    providertype = json['providertype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['provider_id'] = this.providerId;
    data['provider_name'] = this.providerName;
    data['status'] = this.status;
    data['is_featured'] = this.isFeatured;
    data['provider_image'] = this.providerImage;
    data['city_id'] = this.cityId;
    data['providertype_id'] = this.providertypeId;
    data['providertype'] = this.providertype;
    return data;
  }
}