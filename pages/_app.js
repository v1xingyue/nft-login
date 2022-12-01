import '../styles/globals.css'

function MyApp({ Component, pageProps }) {
  if (typeof document !== 'undefined') document.documentElement.classList.add('dark')

  return (
    <div className="h-full">
      <Component {...pageProps} />
    </div>
  )
}

export default MyApp
