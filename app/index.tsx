import { Redirect } from "expo-router";

function Home() {
  return <Redirect href='/(auth)/welcome' />
}

export default Home