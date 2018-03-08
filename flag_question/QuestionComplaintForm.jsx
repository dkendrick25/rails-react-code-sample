import React from 'react'
import PropTypes from 'prop-types'
import { createQuestionComplaint } from '../../requests/index'
import OpenQuestionComplaintForm from '../views/OpenQuestionComplaintForm'
import ClosedQuestionComplaintForm from '../views/ClosedQuestionComplaintForm'
import ErrorMessage from '../common/ErrorMessage'

class QuestionComplaintForm extends React.Component {
  // the reason for flagging a question if factually incorrect or grammatical error
  // but choices could be expanded upon. The description was the feedback submitted
  // by the user about what was wrong with the question.
  state = {
    reason: this.props.reasons[0].reason,
    description: '',
    status: 'closed',
    error: ''
  }
  
  // this function serves for both the drop down(reason) and text input(description)
  // to update the state with the current data
  handleOnChange = (e) => {
    this.setState({[e.target.name]: e.target.value})
  }
  
  // this function clears any previous errors and if the form is valid, submits
  // the data to the server
  handleSubmit = (e) => {
    e.preventDefault()
    this.handleClearError()
    if(this.validateDescription() === true) {
      const params = {
          userId: this.props.user.id,
          questionId: this.props.questionId,
          reason: this.state.reason,
          description: this.state.description
        }
        createQuestionComplaint(params, this.handleSubmitSuccess, this.handleSubmitError)
    }
  }
  
  handleSubmitSuccess = () => {
    this.setState({status: 'submitted'})
  }
  
  
  // this function updates the state with an error message from the server or
  // from a failed validation
  handleSubmitError = (message) => {
    this.setState({error: message})
  }
  
  handleClearError = () => {
    this.setState({ error: '' })
  }
  
  validateDescription = () => {
    const descriptionLength = this.state.description.length
    if(descriptionLength > 240) {
      this.handleSubmitError(`Description is too long. There is a 240 character limit and your message is ${descriptionLength.toLocaleString()} characters long`)
      return false
    } else {
      return true
    }
  }
  
  resetFormState = () => {
    this.setState({
      reason: this.props.reasons[0],
      description: '',
      status: 'closed',
      error: ''
    })
  }
  
  handleStatus = (status) => {
    this.setState({status: status})
  }
  
  renderView = () => {
    switch(this.state.status) {
     case 'closed':
       return <ClosedQuestionComplaintForm onClick={this.handleStatus} />
     case 'open':
       return <OpenQuestionComplaintForm
                 handleSubmit={this.handleSubmit}
                 handleOnChange={this.handleOnChange}
                 handleCancel={this.resetFormState}
                 reasons={this.props.reasons} />
     case 'submitted':
       return <div>Thank You! Your submission has been received</div>
     default:
       return <ClosedQuestionComplaintForm onClick={this.handleStatus} /> }
  }
  
  
  render() {
    return (
      <div>
        <ErrorMessage message={this.state.error} clearError={this.handleClearError}/>
        {this.renderView()} 
      </div>
    )
  }
}

QuestionComplaintForm.propTypes = {
  user:     PropTypes.object.isRequired,
  questionId: PropTypes.number.isRequired,
  reasons: PropTypes.array.isRequired
}

export default QuestionComplaintForm
