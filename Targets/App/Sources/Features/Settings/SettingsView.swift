import SwiftUI
import ComposableArchitecture
import Infra

struct SettingsView: View {
    @Perception.Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationView {
                Form {
                    Section(header: Text("Price Display")) {
                        Picker("Currency Unit", selection: $store.selectedCurrency) {
                            ForEach(CurrencyUnit.allCases) { currency in
                                Text(currency.rawValue).tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    Section(header: Text("Language")) {
                        Picker("App Language", selection: $store.selectedLanguage) {
                            ForEach(SettingsFeature.Language.allCases) { language in
                                Text(language.rawValue).tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .navigationTitle("Settings")
            }
        }
    }
}

#Preview {
    SettingsView(
        store: Store(initialState: SettingsFeature.State()) {
            SettingsFeature()
        }
    )
}
