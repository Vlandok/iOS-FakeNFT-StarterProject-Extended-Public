import SwiftUI

struct EditProfileView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Focus State
    
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case name
        case description
        case website
    }
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel: EditProfileViewModel
    
    // MARK: - Init
    
    init(profile: Profile, onSave: ((Profile) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(profile: profile, onSave: onSave))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            content
            
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .background(Color(.ypWhite))
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .confirmationDialog(
            NSLocalizedString("EditProfile.photoTitle", comment: ""),
            isPresented: $viewModel.showPhotoActionSheet,
            titleVisibility: .visible
        ) {
            photoActionButtons
        }
        .alert(
            NSLocalizedString("EditProfile.photoURLTitle", comment: ""),
            isPresented: $viewModel.showPhotoURLAlert
        ) {
            photoURLAlertContent
        }
        .alert(
            NSLocalizedString("EditProfile.exitConfirmation", comment: ""),
            isPresented: $viewModel.showExitConfirmation
        ) {
            exitConfirmationButtons
        }
        .onChange(of: viewModel.isSaveSuccessful) { _, success in
            if success {
                dismiss()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func hideKeyboard() {
        focusedField = nil
    }
    
    private func saveButtonTapped() {
        hideKeyboard()
        viewModel.saveProfile()
    }
    
    // MARK: - Content
    
    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                avatarSection
                    .frame(maxWidth: .infinity)
                
                nameSection
                    .padding(.top, 24)
                
                descriptionSection
                    .padding(.top, 24)
                
                websiteSection
                    .padding(.top, 24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(Color(.ypWhite))
        }
    }
    
    // MARK: - Avatar Section
    
    private var avatarSection: some View {
        Button(action: viewModel.changePhotoTapped) {
            ZStack(alignment: .bottomTrailing) {
                avatarImage
                
                Image("EditProfileAvatar")
            }
        }
    }
    
    private var avatarImage: some View {
        AsyncImage(url: viewModel.avatarURL) { phase in
            switch phase {
            case .empty:
                avatarPlaceholder
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            case .failure:
                avatarPlaceholder
            @unknown default:
                avatarPlaceholder
            }
        }
    }
    
    private var avatarPlaceholder: some View {
        Image("ProfileUserDefaultAvatar")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 70, height: 70)
            .clipShape(Circle())
    }
    
    // MARK: - Name Section
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("EditProfile.name", comment: ""))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(.ypBlack))
            
            TextField("", text: $viewModel.name)
                .font(.system(size: 17))
                .foregroundColor(Color(.ypBlack))
                .focused($focusedField, equals: .name)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(Color(.ypLightGray))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("EditProfile.description", comment: ""))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(.ypBlack))
            
            TextEditor(text: $viewModel.description)
                .font(.system(size: 17))
                .foregroundColor(Color(.ypBlack))
                .focused($focusedField, equals: .description)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minHeight: 132)
                .background(Color(.ypLightGray))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Website Section
    
    private var websiteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("EditProfile.website", comment: ""))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(.ypBlack))
            
            TextField("", text: $viewModel.website)
                .font(.system(size: 17))
                .foregroundColor(Color(.ypBlack))
                .focused($focusedField, equals: .website)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(Color(.ypLightGray))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Save Button
    
    private var saveButton: some View {
        Button(action: saveButtonTapped) {
            Text(NSLocalizedString("EditProfile.save", comment: ""))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(.ypWhite))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 19)
                .background(Color(.ypBlack))
                .cornerRadius(16)
        }
        .disabled(!viewModel.canSave || viewModel.isLoading)
        .opacity(viewModel.canSave ? 1.0 : 0.5)
    }
    
    // MARK: - Back Button
    
    private var backButton: some View {
        Button {
            if viewModel.backButtonTapped() {
                dismiss()
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(.ypBlack))
        }
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .overlay(
                ProgressView()
                    .tint(Color(.ypWhite))
                    .scaleEffect(1.5)
            )
    }
    
    // MARK: - Photo Action Buttons
    
    @ViewBuilder
    private var photoActionButtons: some View {
        Button(NSLocalizedString("EditProfile.changePhoto", comment: "")) {
            viewModel.changePhotoURLSelected()
        }
        
        Button(NSLocalizedString("EditProfile.deletePhoto", comment: ""), role: .destructive) {
            viewModel.deletePhotoSelected()
        }
        
        Button(NSLocalizedString("EditProfile.cancel", comment: ""), role: .cancel) {}
    }
    
    // MARK: - Photo URL Alert Content
    
    @ViewBuilder
    private var photoURLAlertContent: some View {
        TextField("http://www.example.com", text: $viewModel.photoURLInput)
        
        Button(NSLocalizedString("EditProfile.cancel", comment: ""), role: .cancel) {}
        
        Button(NSLocalizedString("EditProfile.saveURL", comment: "")) {
            viewModel.savePhotoURL()
        }
    }
    
    // MARK: - Exit Confirmation Buttons
    
    @ViewBuilder
    private var exitConfirmationButtons: some View {
        Button(NSLocalizedString("EditProfile.stay", comment: ""), role: .cancel) {}
        
        Button(NSLocalizedString("EditProfile.exit", comment: ""), role: .destructive) {
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    EditProfileView(
        profile: Profile(
            id: "1",
            name: "Joaquin Phoenix",
            description: "Дизайнер из Казани",
            website: "joaquinphoenix.com",
            avatarURL: URL(string: "https://code.s3.yandex.net/landings-v2-ios-developer/space.PNG"),
            nftIds: [],
            likeIds: []
        )
    )
}
