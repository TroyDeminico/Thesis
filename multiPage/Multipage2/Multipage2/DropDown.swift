import SwiftUI

// followed a tutorial for this code
struct DropDown: View {
    let title: String
    let prompt: String
    let options: [String]
    let width: CGFloat // New width parameter
    
    @State private var isExpanded = false
    @Binding var selection: String? // `@Binding` variable

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.gray)
                .opacity(0.8)
            
            VStack {
                HStack {
                    Text(prompt)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .onTapGesture {
                    withAnimation(.snappy) { isExpanded.toggle() }
                }
            }
            if isExpanded {
                VStack {
                    ForEach(options, id: \.self) { option in
                        HStack {
                            Text(option)
                            Spacer()
                            if selection == option {
                                Image(systemName: "checkmark")
                                    .font(.subheadline)
                            }
                        }
                        .frame(height: 40)
                        .padding(.horizontal)
                        .onTapGesture {
                            selection = option
                            isExpanded = false
                        }
                    }
                }
            }
        }
        .frame(maxWidth: width, alignment: .center) // Apply width here
        .padding()
    }
}
