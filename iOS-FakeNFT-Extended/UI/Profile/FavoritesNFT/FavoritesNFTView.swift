import SwiftUI

struct FavoritesNFTView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    
    let favoritesCount: Int
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Избранные NFT")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(.ypBlack))
            
            Text("Количество: \(favoritesCount)")
                .font(.system(size: 17))
                .foregroundColor(Color(.ypBlack))
                .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.ypWhite))
        .navigationTitle(NSLocalizedString("Profile.favoriteNft", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
    }
    
    // MARK: - Back Button
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(.ypBlack))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FavoritesNFTView(favoritesCount: 11)
    }
}
