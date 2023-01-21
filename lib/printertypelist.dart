class PrinterType {
   String bluetoothname;
   String ipname;

  PrinterType(this.bluetoothname, this.ipname);

  PrinterType.fromJson(Map<String, dynamic> json)
      : bluetoothname = json['bluetoothname'],
        ipname = json['ipname'];

  Map<String, dynamic> toJson() => {
        'bluetoothname': bluetoothname,
        'ipname': ipname,
      };
}