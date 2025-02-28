import Foundation

enum Stone: Int {
    case empty = 0
    case black = 1
    case white = 2
    
    var opposite: Stone {
        switch self {
        case .black: return .white
        case .white: return .black
        case .empty: return .empty
        }
    }
}

struct Position: Hashable {
    let x: Int
    let y: Int
    
    var neighbors: [Position] {
        [
            Position(x: x-1, y: y),
            Position(x: x+1, y: y),
            Position(x: x, y: y-1),
            Position(x: x, y: y+1)
        ]
    }
}

class GoBoard {
    static let boardSize = 19
    private var board: [[Stone]]
    var currentPlayer: Stone = .black
    private var libertyCheckBoard: [[Bool]]
    
    init() {
        board = Array(repeating: Array(repeating: .empty, count: GoBoard.boardSize), count: GoBoard.boardSize)
        libertyCheckBoard = Array(repeating: Array(repeating: false, count: GoBoard.boardSize), count: GoBoard.boardSize)
    }
    
    func getStone(at position: Position) -> Stone {
        guard isValidPosition(position) else { return .empty }
        return board[position.y][position.x]
    }
    
    func placeStone(at position: Position) -> Bool {
        guard isValidPosition(position) && getStone(at: position) == .empty else { return false }
        
        // 仮に石を置いてみる
        board[position.y][position.x] = currentPlayer
        
        // 自殺手チェック
        if !hasLiberty(at: position, color: currentPlayer) {
            // 相手の石を取れるかチェック
            var canCapture = false
            for neighbor in position.neighbors where isValidPosition(neighbor) {
                if getStone(at: neighbor) == currentPlayer.opposite && !hasLiberty(at: neighbor, color: currentPlayer.opposite) {
                    canCapture = true
                    removeGroup(at: neighbor)
                }
            }
            
            if !canCapture {
                // 自殺手なので元に戻す
                board[position.y][position.x] = .empty
                return false
            }
        } else {
            // 相手の石を取れるかチェック
            for neighbor in position.neighbors where isValidPosition(neighbor) {
                if getStone(at: neighbor) == currentPlayer.opposite && !hasLiberty(at: neighbor, color: currentPlayer.opposite) {
                    removeGroup(at: neighbor)
                }
            }
        }
        
        currentPlayer = currentPlayer.opposite
        return true
    }
    
    private func hasLiberty(at position: Position, color: Stone) -> Bool {
        libertyCheckBoard = Array(repeating: Array(repeating: false, count: GoBoard.boardSize), count: GoBoard.boardSize)
        return checkLiberty(at: position, color: color)
    }
    
    private func checkLiberty(at position: Position, color: Stone) -> Bool {
        guard isValidPosition(position) else { return false }
        guard !libertyCheckBoard[position.y][position.x] else { return false }
        
        libertyCheckBoard[position.y][position.x] = true
        
        let stone = getStone(at: position)
        if stone == .empty { return true }
        if stone != color { return false }
        
        return position.neighbors.contains { neighbor in
            guard isValidPosition(neighbor) else { return false }
            return checkLiberty(at: neighbor, color: color)
        }
    }
    
    private func removeGroup(at position: Position) {
        guard isValidPosition(position) else { return }
        let color = getStone(at: position)
        guard color != .empty else { return }
        
        board[position.y][position.x] = .empty
        
        for neighbor in position.neighbors {
            if isValidPosition(neighbor) && getStone(at: neighbor) == color {
                removeGroup(at: neighbor)
            }
        }
    }
    
    func isValidPosition(_ position: Position) -> Bool {
        // 盤面の範囲内かどうかをチェック
        return position.x >= 0 && position.x < GoBoard.boardSize &&
               position.y >= 0 && position.y < GoBoard.boardSize
    }
    
    // 地の評価
    func evaluateTerritory() -> Int {
        var blackInfluence = Array(repeating: Array(repeating: 0, count: GoBoard.boardSize), count: GoBoard.boardSize)
        var whiteInfluence = Array(repeating: Array(repeating: 0, count: GoBoard.boardSize), count: GoBoard.boardSize)
        
        // 各石からの影響を計算
        for y in 0..<GoBoard.boardSize {
            for x in 0..<GoBoard.boardSize {
                let position = Position(x: x, y: y)
                let stone = getStone(at: position)
                
                if stone != .empty {
                    if stone == .black {
                        addInfluence(from: position, to: &blackInfluence)
                    } else {
                        addInfluence(from: position, to: &whiteInfluence)
                    }
                }
            }
        }
        
        // 地の計算
        var territory = 0
        for y in 0..<GoBoard.boardSize {
            for x in 0..<GoBoard.boardSize {
                if board[y][x] == .empty {
                    if blackInfluence[y][x] > whiteInfluence[y][x] {
                        territory += 1 // 黒地
                    } else if blackInfluence[y][x] < whiteInfluence[y][x] {
                        territory -= 1 // 白地
                    }
                }
            }
        }
        
        return territory
    }
    
    private func addInfluence(from position: Position, to influence: inout [[Int]]) {
        let range = 3 // 影響範囲（二間飛び）
        
        for dy in -range...range {
            for dx in -range...range {
                let x = position.x + dx
                let y = position.y + dy
                if x >= 0 && x < GoBoard.boardSize && y >= 0 && y < GoBoard.boardSize {
                    // 距離に応じて影響力を減衰
                    let distance = abs(dx) + abs(dy)
                    if distance <= range {
                        influence[y][x] += range - distance + 1
                    }
                }
            }
        }
    }
    
    func copy() -> GoBoard {
        let newBoard = GoBoard()
        newBoard.board = self.board
        newBoard.currentPlayer = self.currentPlayer
        return newBoard
    }
} 
