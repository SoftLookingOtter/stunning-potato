//
//  LoginView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//

import AuthenticationServices
import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var context
    @Bindable var auth: AuthViewModel

    @State private var email    = ""
    @State private var password = ""

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
                            EchoTextField(placeholder: "E-postadress", text: $email, icon: "envelope")
                            EchoSecureField(placeholder: "Lösenord", text: $password)
                        }

                        // MARK: Error
                        if !auth.errorMessage.isEmpty {
                            Text(auth.errorMessage)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.people)
                        }

                        // MARK: Login button
                        PrimaryButton("Logga in", systemImage: "arrow.right") {
                            auth.login(email: email, password: password, context: context)
                        }

                        // MARK: Sign in with Apple
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                auth.signInWithApple(result: result, context: context)
                            }
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

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

// MARK: - Shared text field
struct EchoTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.primary.opacity(0.8))
                .frame(width: 20)

            TextField(text: $text) {
                Text(placeholder)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .font(AppTypography.body)
            .foregroundStyle(AppColors.textPrimary)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surfaceLight)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColors.primary.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Shared password field
struct EchoSecureField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "lock")
                .foregroundStyle(AppColors.primary.opacity(0.8))
                .frame(width: 20)

            if isVisible {
                TextField(text: $text) {
                    Text(placeholder)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            } else {
                SecureField(text: $text) {
                    Text(placeholder)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
            }

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundStyle(AppColors.textMuted)
            }
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
