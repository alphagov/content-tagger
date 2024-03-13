window.GOVUK = window.GOVUK || {}
window.GOVUK.vars = window.GOVUK.vars || {}
window.GOVUK.vars.extraDomains = [
  {
    name: 'production',
    domains: [
      'content-tagger.publishing.service.gov.uk'
    ],
    initialiseGA4: true,
    id: 'GTM-MG7HG5W',
    gaProperty: 'UA-26179049-1',
    gaPropertyCrossDomain: 'UA-145652997-1'
  },
  {
    name: 'staging',
    domains: [
      'content-tagger.staging.publishing.service.gov.uk'
    ],
    initialiseGA4: true,
    id: 'GTM-MG7HG5W',
    auth: 'oJWs562CxSIjZKn_GlB5Bw',
    preview: 'env-5',
    gaProperty: 'UA-26179049-20',
    gaPropertyCrossDomain: 'UA-145652997-1'
  },
  {
    name: 'integration',
    domains: [
      'content-tagger.integration.publishing.service.gov.uk'
    ],
    initialiseGA4: true,
    id: 'GTM-MG7HG5W',
    auth: 'C7iYdcsOlYgGmiUJjZKrHQ',
    preview: 'env-4',
    gaProperty: 'UA-26179049-22',
    gaPropertyCrossDomain: 'UA-145652997-1'
  }
]
