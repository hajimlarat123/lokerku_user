String namaLokasi(String id) {
  switch (id) {
    case 'lokasi01':
      return 'Terminal Arjosari';
    case 'lokasi02':
      return 'Stasiun Malang Kota Baru';
    case 'lokasi03':
      return 'Malang Town Square';
    default:
      return id; // fallback
  }
}

String namaLoker(String lokerId) {
  if (lokerId.startsWith('loker') && lokerId.length > 5) {
    return 'Loker ${lokerId.substring(5)}';
  }
  return lokerId;
}
