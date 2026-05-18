//
//  RegisterView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-18.
//

import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var auth: AuthViewModel

    @State private var name  = ""
    @State private var email = ""

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

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
                        EchoTextField(placeholder: "Ditt namn", text: $name, icon: "person")
                        EchoTextField(placeholder: "E-postadress", text: $email, icon: "envelope")
                    }

                    // MARK: Error
                    if !auth.errorMessage.isEmpty {
                        Text(auth.errorMessage)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.accentRose)
                    }

                    // MARK: Register button
                    PrimaryButton("Registrera", systemImage: "checkmark") {
                        auth.login(name: name, email: email, context: context)
                    }

                    // MARK: Back to login
                    Button("Har du redan ett konto? Logga in") {
                        dismiss()
                    }
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)

                    Spacer(minLength: AppSpacing.xl)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    RegisterView(auth: AuthViewModel())
        .modelContainer(for: [AppUser.self, EchoMemory.self, Route.self], inMemory: true)
}
