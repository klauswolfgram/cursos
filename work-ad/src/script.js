window.onload = () => {

    let url = `https://pokeapi.co/api/v2/pokemon?limit=10`

    const options = {method: 'GET'};
    const req = fetch(url,options);
    const json = req.then(res => res.json());

    json.then((pokes) => listpokes(pokes.results));

    console.log(req,json);
}

const listpokes = async (pokemons) => {

    const myPromise = new Promise((res) => {
        
        const divpokes = document.querySelector('#listpokes');
        
        console.log(divpokes);
        pokemons.forEach((pokemon,i) => {
            setTimeout(() => {
                const pokecard = document.createElement('p');
                pokecard.innerHTML = pokemon.name;
                divpokes.appendChild(pokecard);
                if(i === pokemons.length -1){
                    const loading = document.querySelector('#loading')
                    loading.classList = 'hidden';
                }
            },i * 1000)
        });
    });

    await myPromise.then();
    
}