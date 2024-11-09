import SwiftUI

struct StatusSection: View {
    @Binding var status: ReadingStatus
    let statusColor: Color
    
    var body: some View {
        HStack {
            Text("Status:")
                .font(.headline)
            
            Text(status.rawValue.capitalized)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .foregroundColor(statusColor)
                .cornerRadius(8)
            
            Spacer()
            
            // Show the picker only if the status is not deleted
            if status != .deleted {
                pickerView
            }
        }
    }
    
    @ViewBuilder
    var pickerView: some View {
        Picker("", selection: $status) {
            Text("Unread").tag(ReadingStatus.unread)
            Text("Reading").tag(ReadingStatus.reading)
            Text("Read").tag(ReadingStatus.read)
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(width: 180)
    }
}
