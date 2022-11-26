import { loadStdlib } from '@reach-sh/stdlib';
import * as bekend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

(async () => {


  // const kolikoRundi = stdlib.connector === 'ALGO' ? 3 : 10;
  // console.log(kolikoRundi);); 
  const nalog_Tamara = await stdlib.newTestAccount(stdlib.parseCurrency(1500));  
  const nalog_Aleksa = await stdlib.newTestAccount(stdlib.parseCurrency(1500));

  const fmt = (x) => stdlib.formatCurrency(x, 4);
  const getStanjeNaRacunu = async (igrac) => fmt(await stdlib.balanceOf(igrac));
  const stanjePreTamara = await getStanjeNaRacunu(nalog_Tamara);
  const stanjePreAleksa = await getStanjeNaRacunu(nalog_Aleksa);

  const ugovorTamara = nalog_Tamara.contract(bekend);
  const ugovorAleksa = nalog_Aleksa.contract(bekend, ugovorTamara.getInfo());

  const PRSTI = [0, 1, 2, 3, 4, 5];
  const ODGOVOR = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];  
  const ISHOD = ['Aleksa je pobedio', 'Nereseno', 'Tamara je pobedila'];

  const Igrac = (igrac) => ({
    ...stdlib.hasRandom,
    getPrsti: async () => 
    {
      const prsti = Math.floor(Math.random() * 6);         
      console.log(`${igrac} je bacio ${PRSTI[prsti]} prstiju`);
        
      return prsti;
    },
    getPogodak:  async (fingers) => {
     // pogodak mora biti veci ili jednak od broja prstiju
      const pogodak= Math.floor(Math.random() * 6) + PRSTI[fingers];
     // timeout poneki
      if ( Math.random() <= 0.01 ) {
        for ( let i = 0; i < 10; i++ ) {
          console.log(`  ${igrac} trosi vreme....`);
          await stdlib.wait(1);
        }
      }
      console.log(`${igrac} je rekao  ${pogodak} prstiju`);   
      return pogodak;
    },
    vidiPobednika: (pobednickiBroj) => {    
      console.log(`Stvaran broj bacenih prstiju: ${pobednickiBroj}`);
      console.log(`______________________________`);  
    },

    vidiIshod: (outcome) => {
      console.log(`${igrac} video ishod ${ISHOD[outcome]}`);
    },
    javiTimeout: () => {
      console.log(`${igrac} javio timeout`);
    },
  });

  await Promise.all([
    bekend.Tamara(ugovorTamara, {
      ...Igrac('Tamara'),
      opklada: stdlib.parseCurrency(200),    
      ...stdlib.hasConsoleLogger,
    }),
    bekend.Aleksa(ugovorAleksa, {
      ...Igrac('Aleksa'),
      privhatiOpkladu: (amt) => {      
        console.log(`Aleksa prihvata opkladu u vrednosti od ${fmt(amt)}.`);
      },
      ...stdlib.hasConsoleLogger,      
    }),
  ]);
  const stanjePosleTamara = await getStanjeNaRacunu(nalog_Tamara);
  const stanjePosleAleksa = await getStanjeNaRacunu(nalog_Aleksa);

  console.log(`Tamara pre: ${stanjePreTamara} Tamara posle : ${stanjePosleTamara}.`);
  console.log(`Aleksa pre: ${stanjePreAleksa} Aleksa posle: ${stanjePosleAleksa}.`);


})();