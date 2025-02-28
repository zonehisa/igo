import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published private(set) var board: GoBoard
    @Published private(set) var currentPlayer: Stone
    @Published var alertMessage: String?
    @Published var gameState: GameState = .playing
    @Published var blackPrisoners: Int = 0
    @Published var whitePrisoners: Int = 0
    @Published var territory: Int = 0
    @Published var isComputerThinking = false
    
    private var computerPlayer: ComputerPlayer?
    
    enum GameState {
        case playing
        case finished
    }
    
    enum GameMode {
        case playerVsPlayer
        case playerVsComputer
    }
    
    enum ComputerLevel: Int, CaseIterable {
        case beginner = 0
        case intermediate = 1
        case advanced = 2
        
        var name: String {
            switch self {
            case .beginner: return "初級"
            case .intermediate: return "中級"
            case .advanced: return "上級"
            }
        }
        
        var thinkingTime: TimeInterval {
            switch self {
            case .beginner: return 0.5
            case .intermediate: return 1.0
            case .advanced: return 2.0
            }
        }
    }
    
    private let gameMode: GameMode
    private let computerLevel: ComputerLevel
    
    init(mode: GameMode = .playerVsComputer, level: ComputerLevel = .intermediate) {
        self.gameMode = mode
        self.computerLevel = level
        board = GoBoard()
        currentPlayer = .black
        updateTerritory()
        
        if mode == .playerVsComputer {
            // コンピュータは白番を担当
            computerPlayer = ComputerPlayer(board: board, color: .white, level: level)
        }
    }
    
    func placeStone(at position: Position) {
        guard gameState == .playing else {
            alertMessage = "ゲームは終了しています"
            return
        }
        
        guard !isComputerThinking else { return }
        
        if board.placeStone(at: position) {
            currentPlayer = currentPlayer == .black ? .white : .black
            updateTerritory()
            
            // コンピュータの手番
            if let computer = computerPlayer, currentPlayer == .white {
                computerMove()
            }
        } else {
            alertMessage = "その場所には置けません"
        }
    }
    
    private func computerMove() {
        isComputerThinking = true
        
        // レベルに応じた思考時間を設定
        DispatchQueue.main.asyncAfter(deadline: .now() + computerLevel.thinkingTime) { [weak self] in
            guard let self = self else { return }
            
            if let computerPosition = self.computerPlayer?.selectMove() {
                if self.board.placeStone(at: computerPosition) {
                    self.currentPlayer = .black
                    self.updateTerritory()
                } else {
                    // コンピュータがパスを選択
                    self.pass()
                }
            } else {
                // 置ける場所がない場合はパス
                self.pass()
            }
            
            self.isComputerThinking = false
        }
    }
    
    func pass() {
        if currentPlayer == .white {
            // 両者パスで終局
            gameState = .finished
            alertMessage = "ゲーム終了"
        } else {
            currentPlayer = currentPlayer.opposite
            alertMessage = "\(currentPlayer == .black ? "黒" : "白")の番です"
            
            // コンピュータの手番
            if let computer = computerPlayer, currentPlayer == .white {
                computerMove()
            }
        }
    }
    
    func resign() {
        gameState = .finished
        alertMessage = "\(currentPlayer == .black ? "白" : "黒")の勝ちです"
    }
    
    private func updateTerritory() {
        territory = board.evaluateTerritory()
    }
    
    func getStone(at position: Position) -> Stone {
        return board.getStone(at: position)
    }
    
    func getCurrentPlayerColor() -> Color {
        return currentPlayer == .black ? .black : .white
    }
    
    func getScore() -> String {
        let territoryScore = abs(territory)
        let winner = territory > 0 ? "黒" : "白"
        return "\(winner)の地 \(territoryScore)目"
    }
    
    func resetGame() {
        board = GoBoard()
        currentPlayer = .black
        gameState = .playing
        blackPrisoners = 0
        whitePrisoners = 0
        territory = 0
        alertMessage = nil
        isComputerThinking = false
    }
} 
