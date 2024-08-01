
import SwiftUI

struct DetailView: View {
    var dessert: Dessert

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: dessert.strMealThumb)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .padding()

            Text(dessert.strMeal)
                .font(.title)
                .padding()

            // Add more details like instructions and ingredients here...

            Spacer()
        }
        .navigationTitle(dessert.strMeal)
    }
}
