import SwiftUI

struct PaymentSwiftUIView: View {
    @StateObject private var viewModel: PaymentViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(items: [BasketItem], service: BasketService) {
        _viewModel = StateObject(wrappedValue: PaymentViewModel(items: items, service: service))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                currencyGrid
                
                Spacer()
                
                bottomPanel
            }
            
            // Скрытый NavigationLink для программной навигации
            NavigationLink(
                destination: PaymentSuccessSwiftUIView(),
                isActive: $viewModel.showSuccess
            ) {
                EmptyView()
            }
            .hidden()
            
            if viewModel.isProcessing {
                ProgressHUDView()
            }
        }
        .navigationTitle("Выберите способ оплаты")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image("Light")
                        .renderingMode(.template)
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            viewModel.loadCurrencies()
        }
        .onDisappear {
            // Таббар автоматически показывается через .toolbar(.hidden, for: .tabBar)
        }
    }
    
    private var currencyGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.fixed(168), spacing: 7),
                GridItem(.fixed(168), spacing: 7)
            ], spacing: 7) {
                ForEach(viewModel.currencies) { currency in
                    CurrencyCell(
                        currency: currency,
                        isSelected: viewModel.selectedCurrency?.id == currency.id
                    )
                    .onTapGesture {
                        viewModel.selectCurrency(currency)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }
    
    private var bottomPanel: some View {
        VStack(spacing: 16) {
            agreementText
            
            Button(action: {
                viewModel.pay()
            }) {
                Text("Оплатить")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(viewModel.selectedCurrency == nil ? Color.black.opacity(0.5) : Color.black)
                    .cornerRadius(16)
            }
            .disabled(viewModel.selectedCurrency == nil)
            .padding(.horizontal, 16)
            .padding(.bottom, 0)
        }
        .padding(.top, 16)
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
    }
    
    private var agreementText: some View {
        HStack {
            Text("Совершая покупку, вы соглашаетесь с условиями ")
                .font(.system(size: 13))
                .foregroundColor(.black)
            +
            Text("Пользовательского соглашения")
                .font(.system(size: 13))
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 16)
        .onTapGesture {
            viewModel.showAgreement = true
        }
        .sheet(isPresented: $viewModel.showAgreement) {
            WebView(url: URL(string: "https://yandex.ru/legal/practicum_termsofuse/")!)
        }
    }
}

struct CurrencyCell: View {
    let currency: Currency
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            AsyncImage(url: currency.image) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(currency.title)
                    .font(.system(size: 13))
                    .foregroundColor(.black)
                
                Text(currency.name)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.42, green: 0.69, blue: 0.20))
            }
            
            Spacer()
        }
        .padding(12)
        .frame(width: 168, height: 48)
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.black : Color.clear, lineWidth: 1)
        )
    }
}

struct ProgressHUDView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
    }
}

extension Currency: Identifiable {}
