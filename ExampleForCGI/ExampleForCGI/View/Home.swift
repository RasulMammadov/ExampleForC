//
//  Home.swift
//  ExampleForCGI
//
//  Created by Rasul Mammadov on 19.03.22.
//

import SwiftUI

struct Home: View {
    
    @State var cards: [CardView] = [
    
        CardView(cardColor: Color("blue"), date: "CGI", title: "Conseillers en Gestion et Informatique"),
        CardView(cardColor: Color("orange"), date: "Our Team", title: "★ Torsten Hellfach \n★ Vivien Stumpe \n★ Oliver Langsteiner \n★ İpek Güler \n★ Jinal Bafna \n★ Kevin Wittemann \n★ Jonas Roosen \n★ Thomas Burdzik"),
        CardView(cardColor: Color("brown"), date: "Our Goal is", title: "To be the best!"),
        CardView(cardColor: Color("green"), date: "Our Partners", title: "Volkswagen"),
        CardView(cardColor: Color("red"), date: "Our Services", title: "* Business consulting \n* Systems integration \n* Managed IT Services \n* Application services \n* Infrastructure services \n* Business Process Services"),
    ]
    
    @State var showDetailPage: Bool = false
    @State var currentCard: CardView?
    
    @Namespace var animation
    
    
    var body: some View {
        
        VStack{
            
            //title
            HStack(alignment: .bottom) {
                
                VStack(alignment: .leading) {
                    Image("CGI2")
                        .offset(x: 5)
                    
                    Label {
                        Text("Braunschweig, Deutschland")
                    } icon: {
                        Image(systemName: "location.circle")
                            .offset(x: 5)
                    }
                }
                
                
                Spacer()
                
                Text("Fingers crossed to \npass the interview :)")
                    .font(.caption2)
                    .fontWeight(.light)
                
            }
            
            GeometryReader {proxy in
                
                let size = proxy.size
                
                let trailingCardsToShown: CGFloat = 2
                let trailingSpaceofEachCards: CGFloat = 20
                
                ZStack {
                    
                    ForEach(cards) {card in
                        
                        InfiniteStackedCardView(cards: $cards, card: card, trailingCardsToShown: trailingCardsToShown, trailingCardSpaceofEachCards: trailingSpaceofEachCards, animation: animation, showDetailPage: $showDetailPage)
                        
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    currentCard = card
                                    showDetailPage = true
                                }
                            }
                        
                    }
                    
                }
                
                .padding(.leading,10)
                .padding(.trailing,(trailingCardsToShown * trailingSpaceofEachCards))
                
                    .frame(height: size.height / 1.6)
                
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
                
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(
        
            DetailPage()
        
        )
        
    }
    
    @ViewBuilder
    func DetailPage()->some View {
        
        ZStack {
            
            if let currentCard = currentCard, showDetailPage {
                
                Rectangle()
                    .fill(currentCard.cardColor)
                    .matchedGeometryEffect(id: currentCard.id, in: animation)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 15) {
                    
                    //Close button
                    
                    Button {
                        withAnimation {
                            showDetailPage = false
                        }
                        
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                   
                    Text(currentCard.date)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    Text(currentCard.title)
                        .font(.title.bold())
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        
                        //Info
                        Text(content)
                            .padding(.top)
                        
                    }
                    
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            }
            
        }
        
    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        
        Home()
        
    }
}

struct InfiniteStackedCardView: View {
    
    @Binding var cards: [CardView]
    var card: CardView
    
    var trailingCardsToShown: CGFloat
    var trailingCardSpaceofEachCards: CGFloat
    
    var animation: Namespace.ID
    @Binding var showDetailPage: Bool
    
    @GestureState var isDragging: Bool = false
    @State var offset: CGFloat = .zero
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 15) {
            
            Text(card.date)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(card.title)
                .font(.title.bold())
                .padding(.top)
            
            Spacer()
            
            Label {
                Image(systemName: "arrow.right")
            } icon: {
                Text("Read more")
            }
            .font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .trailing)
            
        }
        .padding()
        .padding(.vertical,10)
        .foregroundColor(.white)
        .background(
        
            ZStack {
                
                RoundedRectangle(cornerRadius: 25)
                    .fill(card.cardColor)
                    .matchedGeometryEffect(id: card.id, in: animation)
            }
        )
        .padding(.trailing,-getPadding())
        .padding(.vertical,getPadding())
        .zIndex(Double(CGFloat(cards.count) - getIndex()))
        .rotationEffect(.init(degrees: getRotation(angle: 10)))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .offset(x: offset)
        .gesture(
            
            DragGesture()
                .updating($isDragging, body: { _, out, _ in
                    out = true
                })
                .onChanged({ value in
                    
                    var translation = value.translation.width
                    translation = cards.first?.id == card.id ? translation : 0
                    translation = isDragging ? translation: 0
                    
                    translation = (translation < 0 ? translation: 0)
                    
                    offset = translation
                })
                .onEnded({ value in
                    
                    let width = UIScreen.main.bounds.width
                    let cardPassed = -offset > (width / 2)
                    
                    
                    withAnimation(.easeInOut(duration: 0.2)){
                        
                        if cardPassed {
                            offset = -width
                            removeAndPutBack()
                        }else {
                        
                        offset = .zero
                        }
                    }
                })
            )
    }
    
    func removeAndPutBack() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            var updatedCard = card
            updatedCard.id = UUID().uuidString
            
            cards.append(updatedCard)
            
            withAnimation {
                cards.removeFirst()
            }
            
        }
        
    }
    
    func getRotation( angle: Double) -> Double {
        
        let width = UIScreen.main.bounds.width - 50
        let progress = offset / width
        
        return Double(progress) * angle
    }
    
    func getPadding() -> CGFloat {
        
        let maxPadding = trailingCardsToShown * trailingCardSpaceofEachCards
        
        let cardPadding = getIndex() * trailingCardSpaceofEachCards
        
        return (getIndex() <= trailingCardsToShown ? cardPadding: maxPadding)
        
    }
    
    func getIndex() -> CGFloat {
        
        let index = cards.firstIndex { card in
            return self.card.id == card.id
        } ?? 0
        
        return CGFloat(index)
    }
    
}

let content = "Founded in 1976, CGI is among the largest IT and business consulting services firms in the world. We are insights-driven and outcome-based to help accelerate returns on your IT and business investments. \nIn all we do, our goal is to build trusted relationships through client proximity, providing industry and technology expertise to help you meet the needs of your customers and citizens. CGI is also a constituent of the S&P/TSX 60, and has a secondary listing on the New York Stock Exchange. \nAfter almost doubling in size with the 1998 acquisition of Bell Sygma, CGI acquired IMRGlobal in 2001 for $438 million, which added 'global delivery options' for CGI. Other significant purchases include American Management Systems (AMS) for $858 million in 2004, which grew CGI's presence in the United States, Europe and Australia and led to the formation of the CGI Federal division. \nCGI Federal's 2010 acquisition of Stanley, Inc. for $1.07 billion almost doubled CGI's presence in the United States, and expanded CGI into defense and intelligence contracts. In 2012, CGI acquired Logica for $2.7 billion Canadian, making CGI the fifth-largest independent business processes and IT services provider in the world, and the biggest tech firm in Canada. In 2016, CGI had assets worth C$20.9 billion, annual sales of $10.7 billion, and a market value of $9.6 billion. As of 2017 CGI is based in forty countries with around 400 offices, and employs approximately 70,000 people. \nAs of March 2015, Canada made up 15% of CGI's client base revenue, and 29% originated from the United States, while around 40% of their commissions came from Europe, and the remaining 15% derived from locales in the rest of the world. \nServices provided by CGI as of 2018 include application services, business consulting, business process services, IT infrastructure services, IT outsourcing services, and systems integration services, among others. CGI has customers in a wide array of industries and markets, with many in financial services. \nCGI also develops products and services for markets such as telecommunications, health, manufacturing, oil and gas, posts and logistics, retail and consumer services, transportation, and utilities. \nClients include both private entities and central governments, state, provincial and local governments, and government departments dealing with defense, intelligence, space, health, human services, public safety, justice, tax, revenue and collections."
