/// Campi firma autore condivisi tra i modelli feed.
class AuthorSignatureFields {
  const AuthorSignatureFields({
    this.signatureHtml,
    this.signaturePlain,
    this.contentShowSignature = true,
  });

  final String? signatureHtml;
  final String? signaturePlain;
  final bool contentShowSignature;

  bool get hasVisibleSignature {
    if (!contentShowSignature) return false;
    final html = signatureHtml?.trim() ?? '';
    final plain = signaturePlain?.trim() ?? '';
    return html.isNotEmpty || plain.isNotEmpty;
  }

  factory AuthorSignatureFields.fromJson(Map<String, dynamic> json) {
    final show = json['content_show_signature'];
    final rawSig = json['signature']?.toString();
    final plainFromApi = json['signature_plain']?.toString();
    final looksHtml = rawSig != null && rawSig.contains('<');
    return AuthorSignatureFields(
      signatureHtml: looksHtml ? rawSig : null,
      signaturePlain: plainFromApi ?? (!looksHtml ? rawSig : null),
      contentShowSignature:
          show == null ? true : show == true || show == 1 || show == '1',
    );
  }

  static AuthorSignatureFields merge(
    AuthorSignatureFields a,
    AuthorSignatureFields b,
  ) {
    final html = (a.signatureHtml?.trim().isNotEmpty == true)
        ? a.signatureHtml
        : b.signatureHtml;
    final plain = (a.signaturePlain?.trim().isNotEmpty == true)
        ? a.signaturePlain
        : b.signaturePlain;
    return AuthorSignatureFields(
      signatureHtml: html,
      signaturePlain: plain,
      contentShowSignature: a.hasVisibleSignature
          ? a.contentShowSignature
          : b.contentShowSignature,
    );
  }
}
