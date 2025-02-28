import SwiftUI

struct BoardView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            // 情報表示エリア
            HStack {
                VStack(alignment: .leading) {
                    Text("手番: \(viewModel.currentPlayer == .black ? "黒" : "白")")
                        .font(.headline)
                }
                Spacer()
                
                // コントロールボタン
                HStack(spacing: 16) {
                    Button("パス") {
                        viewModel.pass()
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isComputerThinking)
                    
                    Button("投了") {
                        viewModel.resign()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    .disabled(viewModel.isComputerThinking)

                    // GameModeSelectionに戻るボタンを追加
                    Button("ゲームモード選択に戻る") {
                        // ゲームをリセット
                        viewModel.resetGame() // ここでゲームをリセットするメソッドを呼び出す
                        // ナビゲーションを使って戻る処理を実装
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // 碁盤
            GeometryReader { geometry in
                let boardSize = min(geometry.size.width, geometry.size.height) * 0.92
                let cellSize = boardSize / CGFloat(GoBoard.boardSize - 1)
                let stoneSize = cellSize * 0.95
                
                ZStack {
                    // 背景
                    Color(red: 0.8, green: 0.6, blue: 0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    // 碁盤のグリッド
                    Path { path in
                        // 縦線
                        for i in 0..<GoBoard.boardSize {
                            let x = CGFloat(i) * cellSize
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: boardSize))
                        }
                        // 横線
                        for i in 0..<GoBoard.boardSize {
                            let y = CGFloat(i) * cellSize
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: boardSize, y: y))
                        }
                    }
                    .stroke(Color.black, lineWidth: 1)
                    
                    // 星の表示
                    ForEach([3, 9, 15], id: \.self) { y in
                        ForEach([3, 9, 15], id: \.self) { x in
                            Circle()
                                .fill(Color.black)
                                .frame(width: 8, height: 8)
                                .position(x: CGFloat(x) * cellSize,
                                        y: CGFloat(y) * cellSize)
                        }
                    }
                    
                    // タップ領域と石の表示
                    ForEach(0..<GoBoard.boardSize, id: \.self) { y in
                        ForEach(0..<GoBoard.boardSize, id: \.self) { x in
                            let stone = viewModel.getStone(at: Position(x: x, y: y))
                            ZStack {
                                // タップ領域（透明な円）
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: cellSize, height: cellSize)
                                    .contentShape(Circle())
                                    .onTapGesture {
                                        viewModel.placeStone(at: Position(x: x, y: y))
                                    }
                                
                                // 石の表示
                                if stone != .empty {
                                    Circle()
                                        .fill(stone == .black ? Color.black : Color.white)
                                        .frame(width: stoneSize, height: stoneSize)
                                        .shadow(radius: 2)
                                    
                                    if stone == .white {
                                        Circle()
                                            .stroke(Color.black, lineWidth: 1)
                                            .frame(width: stoneSize, height: stoneSize)
                                    }
                                }
                            }
                            .position(x: CGFloat(x) * cellSize,
                                    y: CGFloat(y) * cellSize)
                        }
                    }
                }
                .frame(width: boardSize, height: boardSize)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if viewModel.isComputerThinking {
                Text("コンピュータが考え中...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text(viewModel.getScore())
                    .font(.subheadline)
            }
            Spacer()
        }
        .alert("注意", isPresented: .constant(viewModel.alertMessage != nil)) {
            Button("OK") {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
//        .navigationBarHidden(true)
    }
}

#Preview {
    BoardView(viewModel: GameViewModel(mode: .playerVsPlayer))
} 
