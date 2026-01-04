//
//  SessionPicker.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct SessionPicker: View {
    @ObservedObject var sessionManager: SessionManager
    @State private var showingSessionList = false
    @State private var showingNewSession = false
    
    var body: some View {
        Button {
            showingSessionList = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "tray.full.fill")
                    .font(.system(size: 14, weight: .semibold))
                
                Text(sessionManager.currentSession?.name ?? "Session")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.white.opacity(0.1))
                    .overlay(
                        Capsule()
                            .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .sheet(isPresented: $showingSessionList) {
            SessionListSheet(sessionManager: sessionManager, showingNewSession: $showingNewSession)
        }
        .sheet(isPresented: $showingNewSession) {
            NewSessionSheet(sessionManager: sessionManager)
        }
    }
}

// MARK: - Session List Sheet

struct SessionListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var sessionManager: SessionManager
    @Binding var showingNewSession: Bool
    
    @State private var sessionToRename: SessionEntity?
    @State private var newName: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.06, blue: 0.08)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sessionManager.sessions, id: \.id) { session in
                            SessionRow(
                                session: session,
                                isSelected: session.id == sessionManager.currentSession?.id,
                                onSelect: {
                                    sessionManager.switchToSession(session)
                                    dismiss()
                                },
                                onRename: {
                                    newName = session.name ?? ""
                                    sessionToRename = session
                                },
                                onDelete: {
                                    sessionManager.deleteSession(session)
                                },
                                canDelete: sessionManager.sessions.count > 1
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Sessions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingNewSession = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .toolbarBackground(Color(red: 0.06, green: 0.06, blue: 0.08), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Rename Session", isPresented: .init(
                get: { sessionToRename != nil },
                set: { if !$0 { sessionToRename = nil } }
            )) {
                TextField("Session name", text: $newName)
                Button("Cancel", role: .cancel) {
                    sessionToRename = nil
                }
                Button("Rename") {
                    if let session = sessionToRename, !newName.isEmpty {
                        sessionManager.renameSession(session, to: newName)
                    }
                    sessionToRename = nil
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: SessionEntity
    let isSelected: Bool
    let onSelect: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void
    let canDelete: Bool
    
    private var formattedDate: String {
        guard let date = session.createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ time: TimeInterval?) -> String {
        guard let time = time else { return "-" }
        if time < 60 {
            return String(format: "%.2f", time)
        } else {
            let minutes = Int(time) / 60
            let seconds = time.truncatingRemainder(dividingBy: 60)
            return String(format: "%d:%05.2f", minutes, seconds)
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                // Selection indicator
                Circle()
                    .fill(isSelected ? Color.white : Color.clear)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .strokeBorder(.white.opacity(0.3), lineWidth: 1.5)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(session.name ?? "Untitled")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text(session.cubeTypeEnum.displayName)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.1))
                            )
                    }
                    
                    HStack(spacing: 12) {
                        Label("\(session.solveCount) solves", systemImage: "timer")
                        
                        if let best = session.bestTime {
                            Label("Best: \(formatTime(best))", systemImage: "trophy")
                        }
                    }
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? .white.opacity(0.1) : .white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(isSelected ? .white.opacity(0.2) : .clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onRename()
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            if canDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

// MARK: - New Session Sheet

struct NewSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var sessionManager: SessionManager
    
    @State private var sessionName: String = ""
    @State private var selectedCubeType: CubeType = .threeByThree
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.06, blue: 0.08)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Session name
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Session Name", systemImage: "textformat")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        TextField("e.g., Practice, Competition", text: $sessionName)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Cube type
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Cube Type", systemImage: "cube")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(CubeType.allCases) { cubeType in
                                CubeTypeChip(
                                    cubeType: cubeType,
                                    isSelected: selectedCubeType == cubeType
                                ) {
                                    selectedCubeType = cubeType
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        let name = sessionName.isEmpty ? "Session \(sessionManager.sessions.count + 1)" : sessionName
                        sessionManager.createSession(name: name, cubeType: selectedCubeType)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(Color(red: 0.06, green: 0.06, blue: 0.08), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Cube Type Chip

struct CubeTypeChip: View {
    let cubeType: CubeType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(cubeType.displayName)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .black : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? .white : .white.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SessionPicker(sessionManager: SessionManager(context: PersistenceController.preview.container.viewContext))
}

