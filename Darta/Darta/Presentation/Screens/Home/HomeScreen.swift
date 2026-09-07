//
//  HomeScreen.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject var viewModel: HomeScreenViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                renderTopBar()
                renderBalanceCard()
                renderQuickActions()
                renderSecurityNote()
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(
            ZStack {
                Palette.canvas.ignoresSafeArea()
                Palette.radialAmbient.ignoresSafeArea()
            }
        )
    }
}

// MARK: - View Components
private extension HomeScreen {
    func renderTopBar() -> some View {
        HStack(alignment: .center) {
            HStack(spacing: 12) {
                // User Avatar Badge
                ZStack {
                    Circle()
                        .fill(Palette.goldGradient)
                        .frame(width: 44, height: 44)
                        .shadow(color: Palette.amber.opacity(0.3), radius: 6, x: 0, y: 2)

                    Text(avatarInitials)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0x0D/255, green: 0x0D/255, blue: 0x12/255))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Welcome back,")
                        .font(.caption)
                        .foregroundStyle(Palette.muted)

                    Text(viewModel.displayName.isEmpty ? "Darta Member" : viewModel.displayName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                }
            }

            Spacer()

            EyebrowView(text: "VIP Access", iconName: "crown.fill")
        }
    }

    func renderBalanceCard() -> some View {
        BalanceCardView(
            displayName: viewModel.displayName,
            balanceCents: viewModel.balanceCents
        )
    }

    func renderQuickActions() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("QUICK TRANSACTIONS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(Palette.inkSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                if viewModel.isWithdrawEnabled {
                    Button {
                        viewModel.onWithdrawSelected?()
                    } label: {
                        actionCard(
                            icon: "arrow.down.to.line.circle.fill",
                            iconColor: Palette.amber,
                            title: "Withdraw Cash",
                            subtitle: "Create secure cardless QR ticket",
                            badgeText: "POPULAR"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Button {
                    viewModel.onScanSelected?()
                } label: {
                    actionCard(
                        icon: "qrcode.viewfinder",
                        iconColor: Palette.inkSecondary,
                        title: "Cashier Scan Mode",
                        subtitle: "Scan and redeem withdrawal codes",
                        badgeText: "AGENT"
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    func actionCard(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        badgeText: String
    ) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Palette.surfaceElevated)
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Palette.ink)

                    Text(badgeText)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Palette.amber.opacity(0.15))
                        .foregroundStyle(Palette.amberLight)
                        .clipShape(Capsule())
                }

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Palette.muted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Palette.muted)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Palette.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    func renderSecurityNote() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 18))
                .foregroundStyle(Palette.green)

            VStack(alignment: .leading, spacing: 2) {
                Text("Simulated Banking Environment")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.ink)

                Text("All balances and QR redemptions are safely simulated.")
                    .font(.caption2)
                    .foregroundStyle(Palette.muted)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Palette.surfaceElevated.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Palette.border, lineWidth: 1)
        )
    }

    var avatarInitials: String {
        let name = viewModel.displayName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return "D" }
        let components = name.components(separatedBy: " ")
        if components.count >= 2, let first = components.first?.first, let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        } else if let first = name.first {
            return String(first).uppercased()
        }
        return "D"
    }
}
