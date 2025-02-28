import Foundation

class ComputerPlayer {
    private let board: GoBoard
    private let color: Stone
    private let level: GameViewModel.ComputerLevel
    
    init(board: GoBoard, color: Stone, level: GameViewModel.ComputerLevel) {
        self.board = board
        self.color = color
        self.level = level
    }
    
    func selectMove() -> Position? {
        var bestPosition: Position? = nil
        var bestScore = Int.min
        
        // 全ての交差点を評価
        for y in 0..<GoBoard.boardSize {
            for x in 0..<GoBoard.boardSize {
                let position = Position(x: x, y: y)
                
                // その位置に置けるかチェック
                if board.getStone(at: position) == .empty {
                    let score = evaluatePosition(position)
                    if score > bestScore {
                        bestScore = score
                        bestPosition = position
                    }
                }
            }
        }

        return bestPosition
    }
    
    private func evaluatePosition(_ position: Position) -> Int {
        var score = 0
        
        // 1. 基本スコア - 中央に近いほど高評価
        let centerX = GoBoard.boardSize / 2
        let centerY = GoBoard.boardSize / 2
        let distanceFromCenter = abs(position.x - centerX) + abs(position.y - centerY)
        score -= distanceFromCenter
        
        // レベルに応じた評価ロジック
        switch level {
        case .beginner:
            // 初級: 基本的な評価のみ
            score += evaluateBasicPosition(position)
            
        case .intermediate:
            // 中級: 基本評価 + 戦略的な評価
            score += evaluateBasicPosition(position)
            score += evaluateStrategicPosition(position)
            
        case .advanced:
            // 上級: すべての評価 + 高度な戦略
            score += evaluateBasicPosition(position)
            score += evaluateStrategicPosition(position)
            score += evaluateAdvancedPosition(position)
        }
        
        return score
    }
    
    private func evaluateBasicPosition(_ position: Position) -> Int {
        var score = 0
        
        // 1. 隣接する石の評価
        for neighbor in position.neighbors {
            guard board.isValidPosition(neighbor) else { continue }
            let stone = board.getStone(at: neighbor)
            
            if stone == color {
                // 味方の石に隣接 -> 連結を評価
                score += 2
            } else if stone == color.opposite {
                // 敵の石に隣接 -> 攻めの可能性
                score += 1
            }
        }
        
        // 2. 星の位置の評価
        let starPoints = [3, 9, 15]
        if starPoints.contains(position.x) && starPoints.contains(position.y) {
            score += 3
        }
        
        return score
    }
    
    private func evaluateStrategicPosition(_ position: Position) -> Int {
        var score = 0
        
        // 1. 端の評価（端は比較的低評価）
        if position.x == 0 || position.x == GoBoard.boardSize - 1 ||
           position.y == 0 || position.y == GoBoard.boardSize - 1 {
            score -= 2
        }
        
        // 2. 試しに石を置いてみて、自殺手や相手の石を取れる手かを評価
        let tmpBoard = board.copy()
        if tmpBoard.placeStone(at: position) {
            score += 5  // 合法手
            
            // 地の評価
            let territoryScore = tmpBoard.evaluateTerritory()
            score += color == .black ? territoryScore : -territoryScore
        } else {
            score = Int.min  // 非合法手
        }
        
        return score
    }
    
    private func evaluateAdvancedPosition(_ position: Position) -> Int {
        var score = 0
        
        // 1. 相手の石を取れる可能性の評価
        for neighbor in position.neighbors {
            guard board.isValidPosition(neighbor) else { continue }
            let stone = board.getStone(at: neighbor)
            
            if stone == color.opposite {
                // 相手の石の呼吸点をチェック
                let liberties = countLiberties(at: neighbor)
                if liberties == 1 {
                    score += 10  // アタリの石を取れる
                } else if liberties == 2 {
                    score += 5   // 二目の石を狙える
                }
            }
        }
        
        // 2. 自分の石の安全性評価
        for neighbor in position.neighbors {
            guard board.isValidPosition(neighbor) else { continue }
            let stone = board.getStone(at: neighbor)
            
            if stone == color {
                let liberties = countLiberties(at: neighbor)
                if liberties <= 2 {
                    score += 8  // 危険な石を守る
                }
            }
        }
        
        return score
    }
    
    private func countLiberties(at position: Position) -> Int {
        var liberties = 0
        for neighbor in position.neighbors {
            if board.isValidPosition(neighbor) && board.getStone(at: neighbor) == .empty {
                liberties += 1
            }
        }
        return liberties
    }
} 
