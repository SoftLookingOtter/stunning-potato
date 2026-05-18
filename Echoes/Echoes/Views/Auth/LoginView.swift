//
//  LoginView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var context
    @Bindable var auth: AuthViewModel

    @State private var name  = ""
    @State private var email = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.xl) {

                        // MARK: Logo
                        VStack(spacing: AppSpacing.sm) {
                            Image(systemName: "waveform.circle.fill")
                                .font(.system(size: 72))
                                .foregroundStyle(AppColors.primary)
                                .glow(AppColors.primary)

                            Text("Echoes")
                                .font(AppTypography.largeTitle)
                                .foregroundStyle(AppColors.textPrimary)

                            Text("Utforska stadens minnen")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(.top, AppSpacing.xl * 2)

                        // MARK: Fields
                        VStack(spacing: AppSpacing.md) {
                            EchoTextField(placeholder: "Ditt namn", text: $name, icon: "person")
                            EchoTextField(placeholder: "E-postadress", text: $email, icon: "envelope")
                        }

                        // MARK: Error
                        if !auth.errorMessage.isEmpty {
                            Text(auth.errorMessage)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.accentRose)
                        }

                        // MARK: Login button
                        PrimaryButton("Logga in", systemImage: "arrow.right") {
                            auth.login(name: name, email: email, context: context)
                        }

                        // MARK: Register link
                        NavigationLink {
                            RegisterView(auth: auth)
                        } label: {
                            Text("Inget konto? Skapa ett →")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        Spacer(minLength: AppSpacing.xl)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
            }
        }
    }
}

// MARK: - Reusable text field (shared by Login + Register)
struct EchoTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.textMuted)
                .frame(width: 20)

            TextField(placeholder, text: $text)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    LoginView(auth: AuthViewModel())
        .modelContainer(for: [AppUser.self, EchoMemory.self, Route.self], inMemory: true)
}
