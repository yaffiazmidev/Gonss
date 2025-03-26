import Foundation

public enum ResetPasswordPhoneError: String {
    case notFound = "9000"
    
    public static func errorText(
        code: String,
        defaultMessage: String?
    ) -> String {
        switch ResetPasswordPhoneError(rawValue: code) {
        case .notFound:
            return "Nomor telepon belum didaftarkan"
        default:
            return defaultMessage ?? "Terjadi kesalahan. Silahkan coba beberapa saat lagi."
        }
    }
}
