import SwiftUI

struct AddDateTF: View {
    @Binding var date: Date?
    
    @State var month = ""
    @State var day = ""
    @State var year = ""
    
    var body: some View {
        HStack(spacing: 4) {
            TextField("MM", text: $month)
                .frame(width: 50)
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: month) {
                    month = String(month.filter { $0.isNumber }.prefix(2))  // Updated line
                    updateDate()
                }

            TextField("DD", text: $day)
                .frame(width: 50)
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: day) {
                    day = String(day.filter { $0.isNumber }.prefix(2))  // Updated line
                    updateDate()
                }

            TextField("YYYY", text: $year)
                .frame(width: 70)
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: year) {
                    year = String(year.filter { $0.isNumber }.prefix(4))  // Updated line
                    updateDate()
                }
        }
    }
    
    func updateDate() {
        // Complete year before parsing
        guard year.count == 4 else {
            date = nil
            return
        }
        
        // Padded values when month and day are single digits
        let paddedMonth = month.count == 1 ? "0" + month : month
        let paddedDay = day.count == 1 ? "0" + day : day
        
        // Month and day have 1 or 2 digits, and year has 4 digits
        guard let monthInt = Int(paddedMonth), monthInt >= 1, monthInt <= 12,
              let dayInt = Int(paddedDay), dayInt >= 1, dayInt <= 31 else {
            date = nil
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        if let parsedDate = dateFormatter.date(from: "\(paddedMonth)/\(paddedDay)/\(year)") {
            date = parsedDate
        } else {
            date = nil // Set to nil if parsing fails
        }
    }
}
