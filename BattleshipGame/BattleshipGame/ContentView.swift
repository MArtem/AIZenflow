import SwiftUI

struct ContentView: View {
    @StateObject private var game = BattleshipGame()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HeaderView(
                        phase: game.phase,
                        statusText: game.statusText,
                        currentShip: game.currentShip,
                        orientation: game.orientation,
                        canStart: game.canStart,
                        onToggleOrientation: game.toggleOrientation,
                        onStart: game.startGame,
                        onReset: game.reset
                    )

                    VStack(spacing: 18) {
                        BoardSectionView(
                            title: "Your fleet",
                            subtitle: "Place ships here. During the battle, computer shots appear on this board.",
                            board: game.humanBoard,
                            hidesShips: false,
                            isEnabled: game.phase == .placing,
                            action: game.placeShip
                        )

                        BoardSectionView(
                            title: "Enemy waters",
                            subtitle: "After start, tap a cell here to fire.",
                            board: game.targetBoard,
                            hidesShips: true,
                            isEnabled: game.phase == .playing,
                            action: game.fire
                        )
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Battleship")
        }
    }
}

private struct HeaderView: View {
    let phase: GamePhase
    let statusText: String
    let currentShip: ShipDefinition?
    let orientation: Orientation
    let canStart: Bool
    let onToggleOrientation: () -> Void
    let onStart: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(statusText)
                .font(.title3.weight(.semibold))

            if let currentShip {
                Text("Next ship: \(currentShip.name), \(currentShip.length) cells")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button("Rotate: \(orientation.rawValue)", action: onToggleOrientation)
                    .buttonStyle(.bordered)
                    .disabled(phase != .placing)

                Button("Start", action: onStart)
                    .buttonStyle(.borderedProminent)
                    .disabled(!canStart)

                Spacer()

                Button("New game", action: onReset)
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .contain)
    }
}

private struct BoardSectionView: View {
    let title: String
    let subtitle: String
    let board: [[CellState]]
    let hidesShips: Bool
    let isEnabled: Bool
    let action: (Coordinate) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            GameBoardView(
                board: board,
                hidesShips: hidesShips,
                isEnabled: isEnabled,
                action: action
            )
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct GameBoardView: View {
    let board: [[CellState]]
    let hidesShips: Bool
    let isEnabled: Bool
    let action: (Coordinate) -> Void

    private let cellSpacing = 3.0

    var body: some View {
        GeometryReader { proxy in
            let cellSide = max(
                1,
                (proxy.size.width - (cellSpacing * Double(BattleshipGame.boardSize - 1))) / Double(BattleshipGame.boardSize)
            )

            VStack(spacing: cellSpacing) {
                ForEach(0..<BattleshipGame.boardSize, id: \.self) { row in
                    HStack(spacing: cellSpacing) {
                        ForEach(0..<BattleshipGame.boardSize, id: \.self) { column in
                            let coordinate = Coordinate(row: row, column: column)
                            BoardCellButton(
                                state: board[row][column],
                                hidesShip: hidesShips,
                                isEnabled: isEnabled,
                                coordinate: coordinate,
                                action: action
                            )
                            .frame(width: cellSide, height: cellSide)
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Game board"))
    }
}

private struct BoardCellButton: View {
    let state: CellState
    let hidesShip: Bool
    let isEnabled: Bool
    let coordinate: Coordinate
    let action: (Coordinate) -> Void

    var body: some View {
        Button {
            action(coordinate)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(fillColor)

                if let symbolName {
                    Image(systemName: symbolName)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
    }

    private var fillColor: Color {
        switch state {
        case .empty:
            return .blue.opacity(0.18)
        case .ship:
            return hidesShip ? .blue.opacity(0.18) : .gray.opacity(0.75)
        case .hit:
            return .red
        case .miss:
            return .cyan.opacity(0.55)
        }
    }

    private var symbolName: String? {
        switch state {
        case .empty:
            return nil
        case .ship:
            return hidesShip ? nil : "shield.fill"
        case .hit:
            return "flame.fill"
        case .miss:
            return "circle"
        }
    }

    private var accessibilityLabel: Text {
        let position = "row \(coordinate.row + 1), column \(coordinate.column + 1)"
        switch state {
        case .empty:
            return Text("Empty cell, \(position)")
        case .ship:
            return Text(hidesShip ? "Unknown cell, \(position)" : "Ship cell, \(position)")
        case .hit:
            return Text("Hit, \(position)")
        case .miss:
            return Text("Miss, \(position)")
        }
    }
}
