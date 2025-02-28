import SwiftUI

struct GameModeSelectionView: View {
    @State private var selectedComputerLevel: GameViewModel.ComputerLevel = .intermediate
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("囲碁")
                    .font(.largeTitle)
                    .padding(.top, 50)
                
                Spacer()
                
                VStack(spacing: 20) {
                    NavigationLink(destination: BoardView(viewModel: GameViewModel(mode: .playerVsPlayer))) {
                        GameModeButton(title: "対人戦", subtitle: "2人で対戦", systemImage: "person.2.fill")
                    }
                    
                    VStack(spacing: 10) {
                        NavigationLink(destination: BoardView(viewModel: GameViewModel(mode: .playerVsComputer, level: selectedComputerLevel))) {
                            GameModeButton(title: "CPU戦", subtitle: "コンピュータと対戦", systemImage: "cpu.fill")
                        }
                        
                        // コンピュータレベル選択
                        Picker("コンピュータレベル", selection: $selectedComputerLevel) {
                            ForEach(GameViewModel.ComputerLevel.allCases, id: \.self) { level in
                                Text(level.name).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color(red: 0.8, green: 0.6, blue: 0.4))
        }
    }
}

struct GameModeButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title)
                .frame(width: 50)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    GameModeSelectionView()
} 
