//
//  RegisterView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//  Updated by Sara Lindén on 2026-06-03.
//

import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var auth: AuthViewModel

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            StarBackgroundView()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.xl) {

                    // MARK: Header
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 56))
                            .foregroundStyle(AppColors.primary)
                            .glow(AppColors.primary)

                        Text("Skapa konto")
                            .font(AppTypography.title)
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Börja samla och dela dina minnen")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.top, AppSpacing.xl * 2)

                    // MARK: Fields
                    VStack(spacing: AppSpacing.md) {
                        EchoTextField(
                            placeholder: "Ditt namn",
                            text: $name,
                            icon: "person"
                        )

                        EchoTextField(
                            placeholder: "E-postadress",
                            text: $email,
                            icon: "envelope"
                        )

                        EchoSecureField(
                            placeholder: "Lösenord (minst 6 tecken)",
                            text: $password
                        )

                        EchoSecureField(
                            placeholder: "Bekräfta lösenord",
                            text: $confirmPassword
                        )
                    }
                    .onChange(of: name) {
                        auth.errorMessage = ""
                    }
                    .onChange(of: email) {
                        auth.errorMessage = ""
                    }
                    .onChange(of: password) {
                        auth.errorMessage = ""
                    }
                    .onChange(of: confirmPassword) {
                        auth.errorMessage = ""
                    }

                    // MARK: Password mismatch warning
                    if !confirmPassword.isEmpty && password != confirmPassword {
                        Text("Lösenorden matchar inte")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.people)
                    }

                    // MARK: Error
                    if !auth.errorMessage.isEmpty {
                        Text(auth.errorMessage)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.people)
                    }

                    // MARK: Register button
                    PrimaryButton("Registrera", systemImage: "checkmark") {
                        guard password == confirmPassword else {
                            auth.errorMessage = "Lösenorden matchar inte"
                            return
                        }

                        Task {
                            await auth.register(
                                name: name,
                                email: email,
                                password: password,
                                context: context
                            )
                        }
                    }

                    // MARK: Back to login
                    Button {
                        dismiss()
                    } label: {
                        Text("Har du redan ett konto? Logga in")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer(minLength: AppSpacing.xl)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            auth.errorMessage = ""
        }
    }
}

#Preview {
    RegisterView(auth: AuthViewModel())
        .modelContainer(for: [AppUser.self, EchoMemory.self, Route.self], inMemory: true)
}
