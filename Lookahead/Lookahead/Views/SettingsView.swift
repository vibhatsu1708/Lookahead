//
//  SettingsView.swift
//  Lookahead
//
//  Created by Antigravity on 05/01/26.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BackgroundImageEntity.createdAt, ascending: false)],
        animation: .default)
    private var images: FetchedResults<BackgroundImageEntity>
    
    @AppStorage("hideTimer") private var hideTimer = false
    @AppStorage("inspectionEnabled") private var inspectionEnabled = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    if let activeBg = images.first(where: { $0.isCurrent }),
                       let data = activeBg.imageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .ignoresSafeArea()
                            .overlay(Color.black.opacity(0.4))
                    } else {
                        Color(red: 0.06, green: 0.06, blue: 0.08)
                            .ignoresSafeArea()
                        
                        BackgroundGradient(colors: [
                            Color(red: 0.1, green: 0.08, blue: 0.15).opacity(0.6),
                            Color.clear,
                            Color(red: 0.08, green: 0.12, blue: 0.15).opacity(0.4)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                    
                    List {
                        Section {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .foregroundStyle(.blue)
                                    Text("Import Background Image")
                                        .foregroundStyle(.white)
                                }
                            }
                        } header: {
                            Text("Appearance")
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                        
                        Section {
                            Toggle(isOn: $hideTimer) {
                                HStack {
                                    Image(systemName: "eye.slash.fill")
                                        .foregroundStyle(.purple)
                                    Text("Hide Timer While Solving")
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            Toggle(isOn: $inspectionEnabled) {
                                HStack {
                                    Image(systemName: "stopwatch.fill")
                                        .foregroundStyle(.orange)
                                    Text("Inspection Time (15s)")
                                        .foregroundStyle(.white)
                                }
                            }
                        } header: {
                            Text("Timer")
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                        
                        Section {
                            if images.isEmpty {
                                Text("No background images imported")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .listRowBackground(Color.clear)
                            } else {
                                ForEach(images) { imageEntity in
                                    HStack {
                                        if let data = imageEntity.imageData, let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Background Image")
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundStyle(.white)
                                            
                                            if imageEntity.isCurrent {
                                                Text("Active")
                                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                                    .foregroundStyle(.green)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if !imageEntity.isCurrent {
                                            Button("Select") {
                                                setCurrentBackground(imageEntity)
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .tint(.blue)
                                            .font(.system(size: 13, weight: .bold))
                                        } else {
                                            Button("Reset") {
                                                resetBackground()
                                            }
                                            .buttonStyle(.bordered)
                                            .tint(.red)
                                            .font(.system(size: 13, weight: .bold))
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .onDelete(perform: deleteImages)
                            }
                        } header: {
                            Text("Your Backgrounds")
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Settings")
                }
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: selectedItem) { _, newItem in
            if let newItem = newItem {
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        saveImage(data)
                    }
                    selectedItem = nil
                }
            }
        }
    }
    
    private func saveImage(_ data: Data) {
        let newImage = BackgroundImageEntity(context: viewContext)
        newImage.id = UUID()
        newImage.imageData = data
        newImage.createdAt = Date()
        
        // If this is the first image, set it as current automatically
        if images.isEmpty {
            newImage.isCurrent = true
        } else {
            newImage.isCurrent = false
        }
        
        try? viewContext.save()
    }
    
    private func setCurrentBackground(_ image: BackgroundImageEntity) {
        // Reset all others
        for img in images {
            img.isCurrent = false
        }
        image.isCurrent = true
        try? viewContext.save()
    }
    
    private func resetBackground() {
        for img in images {
            img.isCurrent = false
        }
        try? viewContext.save()
    }
    
    private func deleteImages(at offsets: IndexSet) {
        for index in offsets {
            let image = images[index]
            viewContext.delete(image)
        }
        try? viewContext.save()
    }
}
