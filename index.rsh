'reach 0.1';

const [ ishod, DRUGI_POBEDA, NERESENO, PRVI_POBEDA ] = makeEnum(3);
const [ pokusaj, NULAP, JEDANP, DVAP, TRIP, CETIRIP, PETP, SESTP, SEDAMP, OSAMP, DEVETP, DESETP ] = makeEnum(11);
const [ prsti, NULA, JEDAN, DVA, TRI, CETIRI, PET ] = makeEnum(6);


// logika igre
const pobednik = (prvi_prsti, drugi_prsti, pokusaj_prvi, pokusaj_drufi) => { 
  
  if ( pokusaj_prvi == pokusaj_drufi ) 
  {
   const ishod_igre = NERESENO; 
   return ishod_igre;
} else {
 if ( ((prvi_prsti + drugi_prsti) == pokusaj_prvi ) ) {
   const ishod_igre = PRVI_POBEDA;
   return ishod_igre;
 } 
   else {
     if (  ((prvi_prsti + drugi_prsti) == pokusaj_drufi)) {
       const ishod_igre = DRUGI_POBEDA;
       return ishod_igre;
   } 
     else {
       const ishod_igre = NERESENO; 
       return ishod_igre;
     }
   
   }
 }
};


// provere
// Tamara baca a 0, Aleksa baca a 2, 
// Tamara baca 0 and Aleksa pogadja 2
// then Aleksa pobedjuje
assert(pobednik(NULA,DVA,NULAP,DVAP)== DRUGI_POBEDA);
assert(pobednik(DVA,NULA,DVAP,NULAP)== PRVI_POBEDA);
assert(pobednik(NULA,JEDAN,NULAP,DVAP)== NERESENO);
assert(pobednik(JEDAN,JEDAN,JEDANP,JEDANP)== NERESENO);

// za sve kombinacije
forall(UInt, prvi_prsti =>
  forall(UInt, drugi_prsti =>
    forall(UInt, pokusaj_prvi =>
      forall(UInt, pokusaj_drugi =>
    assert(ishod(pobednik(prvi_prsti, drugi_prsti, pokusaj_prvi, pokusaj_drugi)))))));

//  assert za nereseno 
forall(UInt, (prvi_prsti) =>
  forall(UInt, (drugi_prsti) =>       
    forall(UInt, (pogodak) =>
      assert(pobednik(prvi_prsti, drugi_prsti, pogodak, pogodak) == NERESENO))));    

// added a timeout function
const Igrac =
      { ...hasRandom,
        getPrsti: Fun([], UInt),
        getPogodak: Fun([UInt], UInt),
        vidiPobednika: Fun([UInt], Null),
        vidiIshod: Fun([UInt], Null) ,
        javiTimeout: Fun([], Null) // ova funkcija se poziva kada je igrac izgubio zbog vremena
       };
// opklada za Tamaru       
const Tamara =
        { ...Igrac,
          opklada: UInt, 
          ...hasConsoleLogger
        };
// prihvatanje opklade
const Aleksa =
        { ...Igrac,
          privhatiOpkladu: Fun([UInt], Null),
          ...hasConsoleLogger           
        };
const ROK_TRAJANJA = 60; // 60 sekundi

export const main =
  Reach.App(
    {},
    [Participant('Tamara', Tamara), Participant('Aleksa', Aleksa)],
    (Prvi, Drugi) => 
    {
        const javiTimeout = () => 
        {
          each([Prvi, Drugi], () => 
          {
            interact.javiTimeout(); 
          }); 
        };
      Prvi.only(() => 
      {
        const opklada = declassify(interact.opklada); //priv opklada
      });
      Prvi.publish(opklada) // javna opklada
        .pay(opklada); // placanje opklade
      commit();   

      Drugi.only(() => {
        interact.privhatiOpkladu(opklada); }); //prihvata opkladu drugi 
      Drugi.pay(opklada)
        .timeout(relativeTime(ROK_TRAJANJA), () => closeTo(Prvi, javiTimeout)); // ako je vreme isteklo, javiTimeout se poziva

      var ishod12 = NERESENO;      
      invariant(balance() == 2 * opklada && ishod(ishod12) );
      // loop until we have a winner
      while ( ishod12 == NERESENO ) {
        commit();
        Prvi.only(() => {    
          const _prviPrsti = interact.getPrsti();
          const _prviPogodak = interact.getPogodak(_prviPrsti);  
          // prsti u front saljemo      
          interact.log(_prviPrsti);  
          // interact.log(_pogodakPrvi);  
          // treba nam Tamarini prsti i pokusaj ali isto tako moramo da ostavimo tajno , 
            
                      
          const [_commitPrvi, _saltA] = makeCommitment(interact, _prviPrsti);
          const commitPrvi = declassify(_commitPrvi);        
          const [_guessCommitA, _guessSaltA] = makeCommitment(interact, _prviPogodak);
          const guessCommitA = declassify(_guessCommitA);   
      });
     
        Prvi.publish(commitPrvi)
          .timeout(relativeTime(ROK_TRAJANJA), () => closeTo(Drugi, javiTimeout));
        commit();    

        Prvi.publish(guessCommitA)
          .timeout(relativeTime(ROK_TRAJANJA), () => closeTo(Drugi, javiTimeout));
          ;
        commit();
        // Bob does not know the values for Alice, but Alice does know the values 
        unknowable(Drugi, Prvi(_prviPrsti, _saltA));
        unknowable(Drugi, Prvi(_prviPogodak, _guessSaltA));

        Drugi.only(() => {

          const _prstiDrugi = interact.getPrsti();
      //    interact.log(_prstiDrugi);
          const _pogodakDrugi = interact.getPogodak(_prstiDrugi);
      //    interact.log(_pogodakDrugi);
          const prstiDrugi = declassify(_prstiDrugi); 
          const pogodakDrugi = declassify(_pogodakDrugi);  

          });

        Drugi.publish(prstiDrugi)
          .timeout(relativeTime(ROK_TRAJANJA), () => closeTo(Prvi, javiTimeout));
        commit();
        Drugi.publish(pogodakDrugi)
          .timeout(relativeTime(ROK_TRAJANJA), () => closeTo(Prvi, javiTimeout));
          ;
        
        commit();
        // Tamara otkriva svoje prste i pokusaj
        Prvi.only(() => {
          const [saltA, prstiPrvi] = declassify([_saltA, _prviPrsti]); 
          const [guessSaltA, pogodakPrvi] = declassify([_guessSaltA, _prviPogodak]); 

        });
        Prvi.publish(saltA, prstiPrvi)
          .timeout(relativeTime(ROK_TRAJANJA), () => closeTo(Drugi, javiTimeout));
        // provera da li je pokusaj tacan
        checkCommitment(commitPrvi, saltA, prstiPrvi);
        commit();

        Prvi.publish(guessSaltA, pogodakPrvi)
        .timeout(relativeTime(ROK_TRAJANJA), () => closeTo(Drugi, javiTimeout));
        checkCommitment(guessCommitA, guessSaltA, pogodakPrvi);

        commit();
      
        Prvi.only(() => {        
          const PobednickiBroj = prstiPrvi + prstiDrugi;
          interact.vidiPobednika(PobednickiBroj);
        });
     
        Prvi.publish(PobednickiBroj)
        .timeout(relativeTime(ROK_TRAJANJA), () => closeTo(Prvi, javiTimeout));

        ishod12 = pobednik(prstiPrvi, prstiDrugi, pogodakPrvi, pogodakDrugi);
        continue; 
       
      }

      assert(ishod12 == PRVI_POBEDA || ishod12 == DRUGI_POBEDA);
      // salji pare pobedniku
      transfer(2 * opklada).to(ishod12 == PRVI_POBEDA ? Prvi : Drugi);
      commit();
 
      each([Prvi, Drugi], () => {
        interact.vidiIshod(ishod12); })
      exit(); });
