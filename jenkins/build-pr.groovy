def projectName = 'erlang-oauth'
def label = UUID.randomUUID().toString()

podTemplate(
  label: label,
  inheritFrom: 'default',
  serviceAccount: 'jenkins',
  containers: [
    containerTemplate(
      name: 'kaniko',
      image: 'gcr.io/kaniko-project/executor:debug',
      ttyEnabled: true,
      command: '/busybox/cat',
    )
  ]
){
  node(label) {
    stage('Checkout SCM'){
        checkout scm
    }

    stage('Build erlang-oauth and run unit tests') {
      container(name: 'kaniko', shell: '/busybox/sh') {
        sh """#!/busybox/sh
          /kaniko/executor \
             --no-push \
             --cleanup \
             --context $WORKSPACE \
             --dockerfile test.Dockerfile \
             --destination ${projectName}:${label}
         """
      }
    }
  }
}