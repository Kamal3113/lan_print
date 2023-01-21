class Restaurant {
  List<String> printerName;
  String itemLength;
  String template;
  List<Data> data;

  Restaurant({this.printerName,this.itemLength,this.template,this.data});

  Restaurant.fromJson(Map<String, dynamic> json) {
    printerName = json['printer_name'].cast<String>();
    itemLength = json['item_length'];
    template = json['template'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['printer_name'] = this.printerName;
    data['item_length'] = this.itemLength;
    data['template'] = this.template;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String type;
  Object data;

  Data({this.type, this.data});

  Data.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if(type == "header")
    {
      data = json['data'] != null ? new Data1.fromJson(json['data']) : null;
    }
    else if(type == "item"){
data = json['data'] != null ? new Data1.fromJson(json['data']) : null;
    }
      else if(type == "summary"){
data = json['data'] != null ? new Data1.fromJson(json['data']) : null;
    }
      else if(type == "bigsummary"){
data = json['data'] != null ? new Data1.fromJson(json['data']) : null;
    }
      else if(type == "setting"){
data = json['data'] != null ? new Data1.fromJson(json['data']) : null;
    }
        else if(type == "columndetails"){
data = json['data'] != null ? new Data1.fromJson(json['data']) : null;
    }
         else if(type == "Receipt"){
data = json['data'] != null ? new Data1.fromJson(json['data']) : null;
    }
         else if(type == "footer"){
data = json['data'] != null ? new Data1.fromJson(json['data']) : null;
    }
         else if(type == "logo"){
data = json['data'] != null ? new Data1.fromJson(json['data']) : null;
    }
          else if(type == "separator"){
data = json['data'] != null ? new Data1.fromJson(json['data']) : null;
    }
           else if(type == "footer"){
data = json['data'] != null ? new Data1.fromJson(json['data']) : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    return data;
  }
}

class Data1 {
  List<Summary> summary;
  String topTitle;
  List<String> subTitles;
  List<String> address;
  String billNo;
  String ticketNo;
  String dateOfBill;
  String preprationDate;
  String time;
  String print;
  String table;
  String onlineOrderId;
  String employee;
  String till;
  String orderType;
  String customerName;
  String customerPhone;
  List<String> customerAddress;
  List<String> customerRemarks;
  String splitBillString;
  List<String> headercomments;
  String separatorLength;
  List<Itemdata> itemdata;
  List<Bigsummary> bigsummary;
  List<String> printerName;
  String printType;
  int itemLength;
  bool printLogo;
  String thankyouNote;
  String thankyouNote2;
  String printerType;
  Columnheader columnheader;
  List<Columndata> columndata;
  String align;
  List<String> receiptText;
  List<String> footerText;
  String url;

  Data1(
      {this.summary,
      this.topTitle,
      this.subTitles,
      this.address,
      this.billNo,
      this.ticketNo,
      this.dateOfBill,
      this.preprationDate,
      this.time,
      this.print,
      this.table,
      this.onlineOrderId,
      this.employee,
      this.till,
      this.orderType,
      this.customerName,
      this.customerPhone,
      this.customerAddress,
      this.customerRemarks,
      this.splitBillString,
      this.headercomments,
      this.separatorLength,
      this.itemdata,
      this.bigsummary,
      this.printerName,
      this.printType,
      this.itemLength,
      this.printLogo,
      this.thankyouNote,
      this.thankyouNote2,
      this.printerType,
      this.columnheader,
      this.columndata,
      this.align,
      this.receiptText,
      this.footerText,
      this.url});

  Data1.fromJson(Map<String, dynamic> json) {
      if (json['summary'] != null) {
      summary = <Summary>[];
      json['summary'].forEach((v) {
        summary.add(new Summary.fromJson(v));
      });
    }topTitle = json['top_title'];
    subTitles = json['sub_titles'] == null? [] : List<String>.from(json["sub_titles"].map((x) => x));
    address = json['address'] == null? [] : List<String>.from(json["address"].map((x) => x));
    billNo = json['bill_no'];
    ticketNo = json['ticket_no'];
    dateOfBill = json['date_of_bill'];
    preprationDate = json['prepration_date'];
    time = json['time'];
    print = json['print'];
    table = json['table'];
    onlineOrderId = json['online_order_id'];
    employee = json['employee'];
    till = json['till'];
    orderType = json['order_type'];
    customerName = json['customer_name'];
    customerPhone = json['customer_phone'];
    customerAddress = json['customer_address']== null? [] : List<String>.from(json["customer_address"].map((x) => x));
    customerRemarks = json['customer_remarks']== null? [] : List<String>.from(json["customer_remarks"].map((x) => x));
    splitBillString = json['split_bill_string'];
    headercomments = json['headercomments']== null? [] : List<String>.from(json["headercomments"].map((x) => x));
    separatorLength = json['separator_length'];
    if (json['itemdata'] != null) {
      itemdata = <Itemdata>[];
      json['itemdata'].forEach((v) {
        itemdata.add(new Itemdata.fromJson(v));
      });
    }
     if (json['bigsummary'] != null) {
      bigsummary = <Bigsummary>[];
      json['bigsummary'].forEach((v) {
        bigsummary.add(new Bigsummary.fromJson(v));
      });
    }
    printerName = json['printer_name']== null? [] : List<String>.from(json["printer_name"].map((x) => x));
    printType = json['print_type'];
    itemLength = json['item_length'];
    printLogo = json['print_logo'];
    thankyouNote = json['thankyou_note'];
    thankyouNote2 = json['thankyou_note2'];
    printerType = json['printer_type'];
    columnheader = json['columnheader'] != null
        ? new Columnheader.fromJson(json['columnheader'])
        : null;
    if (json['columndata'] != null) {
      columndata = <Columndata>[];
      json['columndata'].forEach((v) {
        columndata.add(new Columndata.fromJson(v));
      });
    }
    align = json['align'];
    receiptText = json['receipt_text']== null? [] : List<String>.from(json["receipt_text"].map((x) => x));
    footerText = json['footer_text']== null? [] : List<String>.from(json["footer_text"].map((x) => x));
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.summary != null) {
      data['summary'] = this.summary.map((v) => v.toJson()).toList();
    }
    data['top_title'] = this.topTitle;
    data['sub_titles'] = this.subTitles;
    data['address'] = this.address;
    data['bill_no'] = this.billNo;
    data['ticket_no'] = this.ticketNo;
    data['date_of_bill'] = this.dateOfBill;
    data['prepration_date'] = this.preprationDate;
    data['time'] = this.time;
    data['print'] = this.print;
    data['table'] = this.table;
    data['online_order_id'] = this.onlineOrderId;
    data['employee'] = this.employee;
    data['till'] = this.till;
    data['order_type'] = this.orderType;
    data['customer_name'] = this.customerName;
    data['customer_phone'] = this.customerPhone;
    data['customer_address'] = this.customerAddress;
    data['customer_remarks'] = this.customerRemarks;
    data['split_bill_string'] = this.splitBillString;
    data['headercomments'] = this.headercomments;
    data['separator_length'] = this.separatorLength;
    if (this.itemdata != null) {
      data['itemdata'] = this.itemdata.map((v) => v.toJson()).toList();
    }
    if (this.bigsummary != null) {
      data['bigsummary'] = this.bigsummary.map((v) => v.toJson()).toList();
    }
    data['printer_name'] = this.printerName;
    data['print_type'] = this.printType;
    data['item_length'] = this.itemLength;
    data['print_logo'] = this.printLogo;
    data['thankyou_note'] = this.thankyouNote;
    data['thankyou_note2'] = this.thankyouNote2;
    data['printer_type'] = this.printerType;
    if (this.columnheader != null) {
      data['columnheader'] = this.columnheader.toJson();
    }
    if (this.columndata != null) {
      data['columndata'] = this.columndata.map((v) => v.toJson()).toList();
    }
    data['align'] = this.align;
    data['receipt_text'] = this.receiptText;
    data['footer_text'] = this.footerText;
    data['url'] = this.url;
    return data;
  }
}

class Itemdata {
  int orderInvoiceId;
  double itemAmount;
  String itemName;
  String itemSubLine;
  List<String> toppingsWithPrice;
  List<String> toppings;
  int quantity;
  bool selected;
  double price;
  String custpmerRemarks;
  String printerName;
  String printerLabel;
  String station;
  String foodStampable;
  List<Items> items;
  String printDescription;
  bool deleted;
  bool exists;
  int displayIndex;
  bool isPrinted;
  bool madeTo;
  String menuGroup;
  bool kitchenPrint;

  Itemdata(
      {this.orderInvoiceId,
      this.itemAmount,
      this.itemName,
      this.itemSubLine,
      this.toppingsWithPrice,
      this.toppings,
      this.quantity,
      this.selected,
      this.price,
      this.custpmerRemarks,
      this.printerName,
      this.printerLabel,
      this.station,
      this.foodStampable,
      this.items,
      this.printDescription,
      this.deleted,
      this.exists,
      this.displayIndex,
      this.isPrinted,
      this.madeTo,
      this.menuGroup,
      this.kitchenPrint});

  Itemdata.fromJson(Map<String, dynamic> json) {
    orderInvoiceId = json['order_invoice_id'];
    itemAmount = json['item_amount'];
    itemName = json['item_name'];
    itemSubLine = json['item_subLine'];
    toppingsWithPrice = json['toppings_with_price'] == null? [] : List<String>.from(json["toppings_with_price"].map((x) => x));
    toppings = json['toppings'] == null? [] : List<String>.from(json["toppings"].map((x) => x));
    quantity = json['quantity'];
    selected = json['selected'];
    price = json['price'];
    custpmerRemarks = json['custpmer_remarks'];
    printerName = json['printer_name'];
    printerLabel = json['printer_label'];
    station = json['station'];
    foodStampable = json['food_stampable'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items.add(new Items.fromJson(v));
      });
    }
    printDescription = json['print_description'];
    deleted = json['deleted'];
    exists = json['exists'];
    displayIndex = json['display_index'];
    isPrinted = json['is_printed'];
    madeTo = json['made_to'];
    menuGroup = json['menu_group'];
    kitchenPrint = json['kitchen_print'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_invoice_id'] = this.orderInvoiceId;
    data['item_amount'] = this.itemAmount;
    data['item_name'] = this.itemName;
    data['item_subLine'] = this.itemSubLine;
    data['toppings_with_price'] = this.toppingsWithPrice;
    data['toppings'] = this.toppings;
    data['quantity'] = this.quantity;
    data['selected'] = this.selected;
    data['price'] = this.price;
    data['custpmer_remarks'] = this.custpmerRemarks;
    data['printer_name'] = this.printerName;
    data['printer_label'] = this.printerLabel;
    data['station'] = this.station;
    data['food_stampable'] = this.foodStampable;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    data['print_description'] = this.printDescription;
    data['deleted'] = this.deleted;
    data['exists'] = this.exists;
    data['display_index'] = this.displayIndex;
    data['is_printed'] = this.isPrinted;
    data['made_to'] = this.madeTo;
    data['menu_group'] = this.menuGroup;
    data['kitchen_print'] = this.kitchenPrint;
    return data;
  }
}

class Items {
  String orderInvoiceId;
  int itemAmount;
  String itemName;
  String itemSubLine;
  List<String> toppingsWithPrice;
  List<String> toppings;
  int quantity;
  bool selected;
  int price;
  String custpmerRemarks;
  String printerName;
  String printerLabel;
  String station;
  String foodStampable;
  List<String> items;
  String printDescription;
  bool deleted;
  bool exists;
  int displayIndex;
  bool isPrinted;
  bool madeTo;
  List<String> menuGroup;
  bool kitchenPrint;

  Items(
      {this.orderInvoiceId,
      this.itemAmount,
      this.itemName,
      this.itemSubLine,
      this.toppingsWithPrice,
      this.toppings,
      this.quantity,
      this.selected,
      this.price,
      this.custpmerRemarks,
      this.printerName,
      this.printerLabel,
      this.station,
      this.foodStampable,
      this.items,
      this.printDescription,
      this.deleted,
      this.exists,
      this.displayIndex,
      this.isPrinted,
      this.madeTo,
      this.menuGroup,
      this.kitchenPrint});

  Items.fromJson(Map<String, dynamic> json) {
    orderInvoiceId = json['order_invoice_id'];
    itemAmount = json['item_amount'];
    itemName = json['item_name'];
    itemSubLine = json['item_subLine'];
    toppingsWithPrice = json['toppings_with_price'] == null? [] : List<String>.from(json["toppings_with_price"].map((x) => x));
    toppings = json['toppings'] == null? [] : List<String>.from(json["toppings"].map((x) => x));
    quantity = json['quantity'];
    selected = json['selected'];
    price = json['price'];
    custpmerRemarks = json['custpmer_remarks'];
    printerName = json['printer_name'];
    printerLabel = json['printer_label'];
    station = json['station'];
    foodStampable = json['food_stampable'];
    items = json['items'] == null? [] : List<String>.from(json["items"].map((x) => x));
    printDescription = json['print_description'];
    deleted = json['deleted'];
    exists = json['exists'];
    displayIndex = json['display_index'];
    isPrinted = json['is_printed'];
    madeTo = json['made_to'];
    menuGroup = json['menu_group'] == null? [] : List<String>.from(json["menu_group"].map((x) => x));
    kitchenPrint = json['kitchen_print'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_invoice_id'] = this.orderInvoiceId;
    data['item_amount'] = this.itemAmount;
    data['item_name'] = this.itemName;
    data['item_subLine'] = this.itemSubLine;
    data['toppings_with_price'] = this.toppingsWithPrice;
    data['toppings'] = this.toppings;
    data['quantity'] = this.quantity;
    data['selected'] = this.selected;
    data['price'] = this.price;
    data['custpmer_remarks'] = this.custpmerRemarks;
    data['printer_name'] = this.printerName;
    data['printer_label'] = this.printerLabel;
    data['station'] = this.station;
    data['food_stampable'] = this.foodStampable;
    data['items'] = this.items;
    data['print_description'] = this.printDescription;
    data['deleted'] = this.deleted;
    data['exists'] = this.exists;
    data['display_index'] = this.displayIndex;
    data['is_printed'] = this.isPrinted;
    data['made_to'] = this.madeTo;
    data['menu_group'] = this.menuGroup;
    data['kitchen_print'] = this.kitchenPrint;
    return data;
  }
}

class Columnheader {
  String column1;
  String column2;
  String column3;
  String column4;

  Columnheader({this.column1, this.column2, this.column3, this.column4});

  Columnheader.fromJson(Map<String, dynamic> json) {
    column1 = json['column1'];
    column2 = json['column2'];
    column3 = json['column3'];
    column4 = json['column4'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['column1'] = this.column1;
    data['column2'] = this.column2;
    data['column3'] = this.column3;
    data['column4'] = this.column4;
    return data;
  }
}
class Columndata {
  String column1;
  String column2;
  String column3;
  String column4;

  Columndata({this.column1, this.column2, this.column3, this.column4});

  Columndata.fromJson(Map<String, dynamic> json) {
    column1 = json['column1'];
    column2 = json['column2'];
    column3 = json['column3'];
    column4 = json['column4'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['column1'] = this.column1;
    data['column2'] = this.column2;
    data['column3'] = this.column3;
    data['column4'] = this.column4;
    return data;
  }
}
class Summary {
  String key;
  double value;

  Summary({this.key, this.value});

  Summary.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}
class Bigsummary {
  String key;
  double value;

  Bigsummary({this.key, this.value});

  Bigsummary.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}