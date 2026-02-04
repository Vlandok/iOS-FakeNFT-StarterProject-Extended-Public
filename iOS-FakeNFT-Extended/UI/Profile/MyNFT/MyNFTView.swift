import SwiftUI

struct MyNFTView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    
    let nftCount: Int
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Мои NFT")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(.ypBlack))
            
            Text("Количество: \(nftCount)")
                .font(.system(size: 17))
                .foregroundColor(Color(.ypBlack))
                .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.ypWhite))
        .navigationTitle(NSLocalizedString("Profile.myNft", comment: ""))
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
        MyNFTView(nftCount: 112)
    }
}
