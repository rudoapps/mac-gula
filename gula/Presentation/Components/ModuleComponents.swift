import SwiftUI

// MARK: - Module List Row

struct ModuleListRow: View {
    let module: Module
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Module Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    isSelected ? Color.blue : Color.secondary.opacity(0.6),
                                    isSelected ? Color.cyan : Color.secondary.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .shadow(color: (isSelected ? Color.blue : Color.secondary).opacity(0.2), radius: 2, x: 0, y: 1)
                    
                    Image(systemName: module.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Module Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.displayName)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(module.description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Category Badge
                Text(module.category.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.blue.opacity(0.3) : Color.secondary.opacity(0.1))
                    )
                
                // Installation Status Indicator
                installationStatusView
                
                // Selection Indicator
                if module.installationStatus == .notInstalled {
                    ZStack {
                        Circle()
                            .fill(
                                isSelected 
                                    ? LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color.secondary.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        isSelected ? Color.clear : Color.secondary.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                            .frame(width: 20, height: 20)
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected 
                            ? LinearGradient(colors: [.blue.opacity(0.6), .cyan.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.secondary.opacity(isHovered ? 0.3 : 0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(
                color: isSelected ? Color.blue.opacity(0.15) : Color.black.opacity(isHovered ? 0.04 : 0.02),
                radius: isSelected ? 4 : (isHovered ? 3 : 2),
                x: 0,
                y: isSelected ? 2 : 1
            )
            .scaleEffect(isHovered ? 1.005 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    @ViewBuilder
    private var installationStatusView: some View {
        switch module.installationStatus {
        case .notInstalled:
            EmptyView()
        case .installing:
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.7)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                Text("Instalando...")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.blue)
            }
        case .installed:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.green)
                Text("Instalado")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.green)
            }
        case .failed(let error):
            HStack(spacing: 6) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.red)
                Text("Error")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.red)
            }
            .help(error)
        }
    }
}

// MARK: - Compact Module Card

struct CompactModuleCard: View {
    let module: Module
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Module Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    isSelected ? Color.blue : Color.secondary.opacity(0.6),
                                    isSelected ? Color.cyan : Color.secondary.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                        .shadow(color: (isSelected ? Color.blue : Color.secondary).opacity(0.2), radius: 2, x: 0, y: 1)
                    
                    Image(systemName: module.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Module Info
                VStack(spacing: 4) {
                    Text(module.displayName)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                    
                    Text(module.description)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Selection Indicator
                ZStack {
                    Circle()
                        .fill(
                            isSelected 
                                ? LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.secondary.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? Color.clear : Color.secondary.opacity(0.3),
                                    lineWidth: 0.5
                                )
                        )
                        .frame(width: 16, height: 16)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                isSelected 
                                    ? LinearGradient(colors: [.blue.opacity(0.6), .cyan.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color.secondary.opacity(isHovered ? 0.3 : 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: isSelected ? 1.5 : 0.5
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color.blue.opacity(0.15) : Color.black.opacity(isHovered ? 0.04 : 0.02),
                radius: isSelected ? 4 : (isHovered ? 3 : 2),
                x: 0,
                y: isSelected ? 2 : 1
            )
            .scaleEffect(isHovered ? 1.01 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Enhanced Module Card

struct EnhancedModuleCard: View {
    let module: Module
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Module Header
                HStack(spacing: 12) {
                    // Module Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        isSelected ? Color.blue : Color.secondary.opacity(0.6),
                                        isSelected ? Color.cyan : Color.secondary.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(color: (isSelected ? Color.blue : Color.secondary).opacity(0.3), radius: 6, x: 0, y: 3)
                        
                        Image(systemName: module.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(module.displayName)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(module.description)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                
                // Selection Indicator
                HStack {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                isSelected 
                                    ? LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.secondary.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(
                                        isSelected ? Color.clear : Color.secondary.opacity(0.3),
                                        lineWidth: 1.5
                                    )
                            )
                            .frame(width: 28, height: 28)
                            .shadow(
                                color: isSelected ? Color.blue.opacity(0.3) : Color.clear,
                                radius: isSelected ? 4 : 0,
                                x: 0,
                                y: 2
                            )
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: isSelected)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        isSelected 
                                            ? Color.blue.opacity(0.6) 
                                            : (isHovered ? Color.secondary.opacity(0.4) : Color.secondary.opacity(0.2)),
                                        isSelected 
                                            ? Color.cyan.opacity(0.4) 
                                            : (isHovered ? Color.secondary.opacity(0.2) : Color.secondary.opacity(0.1))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected 
                    ? Color.blue.opacity(0.2) 
                    : Color.black.opacity(isHovered ? 0.08 : 0.04),
                radius: isSelected ? 12 : (isHovered ? 10 : 6),
                x: 0,
                y: isSelected ? 6 : (isHovered ? 4 : 2)
            )
            .scaleEffect(
                isPressed ? 0.95 : (isHovered ? 1.03 : 1.0)
            )
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}